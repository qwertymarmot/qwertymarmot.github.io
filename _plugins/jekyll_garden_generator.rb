# Jekyll Garden Generator
# Generates search index and graph data for Jekyll Garden

require 'json'
require 'fileutils'

# Register a hook to copy files after site generation
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Post-write hook executed"
  
  # Copy search-index.json from the destination directory to the source directory
  search_index_dest_path = File.join(site.dest, 'search-index.json')
  search_index_source_path = File.join(site.source, 'search-index.json')
  
  if File.exist?(search_index_dest_path)
    FileUtils.cp(search_index_dest_path, search_index_source_path)
    puts "Copied search-index.json from #{search_index_dest_path} to #{search_index_source_path}"
    puts "File exists in source after copy: #{File.exist?(search_index_source_path)}"
  else
    puts "Destination file #{search_index_dest_path} does not exist"
  end
  
  # Copy graph-data.json from the destination directory to the source directory
  graph_data_dest_path = File.join(site.dest, 'graph-data.json')
  graph_data_source_path = File.join(site.source, 'graph-data.json')
  
  if File.exist?(graph_data_dest_path)
    FileUtils.cp(graph_data_dest_path, graph_data_source_path)
    puts "Copied graph-data.json from #{graph_data_dest_path} to #{graph_data_source_path}"
    puts "File exists in source after copy: #{File.exist?(graph_data_source_path)}"
  else
    puts "Destination file #{graph_data_dest_path} does not exist"
  end
end

module JekyllGarden
  class SearchIndexGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      # Generate search index
      documents = []
      
      # Add notes to search index
      site.collections['notes']&.docs&.each do |note|
        next if note.data['exclude_from_search']
        
        documents << {
          'id' => note.basename_without_ext,
          'title' => note.data['title'] || note.basename_without_ext.tr('-', ' ').capitalize,
          'content' => note.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip,
          'url' => note.url,
          'tags' => note.data['tags'],
          'type' => note.data['type'] || 'evergreen',
          'date' => note.data['date']&.strftime('%Y-%m-%d'),
          'last_modified_at' => note.data['last_modified_at']&.strftime('%Y-%m-%d')
        }
      end
      
      # Add books to search index
      site.collections['books']&.docs&.each do |book|
        next if book.data['exclude_from_search']
        
        documents << {
          'id' => book.basename_without_ext,
          'title' => book.data['title'] || book.basename_without_ext.tr('-', ' ').capitalize,
          'content' => book.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip,
          'url' => book.url,
          'tags' => book.data['tags'],
          'type' => 'book',
          'date' => book.data['date']&.strftime('%Y-%m-%d'),
          'last_modified_at' => book.data['last_modified_at']&.strftime('%Y-%m-%d')
        }
      end
      
      # Create search index file
      search_index = {
        'documents' => documents
      }
      
      # Debug output
      puts "Generating search index with #{documents.length} documents"
      puts "Writing search index to #{File.join(site.dest, 'search-index.json')}"
      
      # Write search index to both the destination directory and the source directory
      search_index_path = File.join(site.dest, 'search-index.json')
      search_index_source_path = File.join(site.source, 'search-index.json')
      
      FileUtils.mkdir_p(site.dest) unless File.directory?(site.dest)
      begin
        # Write to destination directory
        File.write(search_index_path, JSON.pretty_generate(search_index))
        puts "Search index written successfully to #{search_index_path}"
        puts "File exists in dest: #{File.exist?(search_index_path)}"
        
        # Also write to source directory as a fallback
        File.write(search_index_source_path, JSON.pretty_generate(search_index))
        puts "Search index also written to #{search_index_source_path}"
        puts "File exists in source: #{File.exist?(search_index_source_path)}"
      rescue => e
        puts "Error writing search index: #{e.message}"
        puts e.backtrace.join("\n")
      end
      
      # Generate graph data
      nodes = []
      links = []
      
      all_notes = site.collections['notes']&.docs || []
      all_books = site.collections['books']&.docs || []
      all_docs = all_notes + all_books
      
      # Debug output for all documents
      puts "All documents:"
      all_docs.each do |doc|
        puts "  #{doc.basename_without_ext} (#{doc.collection.label})"
      end
      
      # Process all documents to find wikilinks and create nodes
      all_docs.each do |doc|
        next if doc.data['exclude_from_graph']
        
        # Create node
        doc_type = doc.collection.label == 'books' ? 'book' : (doc.data['type'] || 'evergreen')
        
        node = {
          'id' => doc.basename_without_ext,
          'title' => doc.data['title'] || doc.basename_without_ext.tr('-', ' ').capitalize,
          'url' => doc.url,
          'type' => doc_type
        }
        
        # Add excerpt if available
        if doc.content.length > 150
          node['excerpt'] = doc.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip[0...150] + '...'
        else
          node['excerpt'] = doc.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip
        end
        
        puts "Adding node: #{node['id']} (#{node['type']})"
        nodes << node
        
        # Find wikilinks in content
        wikilinks = doc.content.scan(/\[\[(.*?)\]\]/)
        
        puts "Found #{wikilinks.length} wikilinks in #{doc.basename_without_ext}"
        
        wikilinks.each do |link|
          link_text = link[0].strip
          puts "  Processing wikilink: #{link_text}"
          
          # Determine target collection and prepare slug text
          target_collection = 'notes'
          slug_text = link_text
          
          if link_text.start_with?('Book:')
            target_collection = 'books'
            slug_text = link_text[5..-1].strip  # Remove 'Book:' prefix for slug
            puts "  Book link detected, slug_text: #{slug_text}, target_collection: #{target_collection}"
          end
          
          # Create slug
          slug = slug_text.downcase
            .gsub(/\s+/, '-')
            .gsub(/[^\w\-]/, '')
            .gsub(/-{2,}/, '-')
            .gsub(/^-|-$/, '')
          
          # Add link
          link_data = {
            'source' => doc.basename_without_ext,
            'target' => slug,
            'type' => target_collection
          }
          puts "  Adding link: #{link_data.inspect}"
          links << link_data
        end
      end
      
      # Process backlinks
      all_docs.each do |current_doc|
        # Find documents that link to the current document
        docs_linking_to_current = all_docs.filter do |other_doc|
          other_doc.url != current_doc.url && 
          (
            # Check for explicit wikilinks
            other_doc.content.include?("[[#{current_doc.data['title']}]]") ||
            other_doc.content.include?("[[#{current_doc.basename_without_ext.tr('-', ' ').capitalize}]]") ||
            # Check for book links
            (current_doc.collection.label == 'books' && 
             (other_doc.content.include?("[[Book: #{current_doc.data['title']}]]") ||
              other_doc.content.include?("[[Book: #{current_doc.basename_without_ext.tr('-', ' ').capitalize}]]"))) ||
            # Check for links with custom text
            other_doc.content.match(/\[\[#{Regexp.escape(current_doc.data['title'] || current_doc.basename_without_ext.tr('-', ' ').capitalize)}\|.*?\]\]/) ||
            # Check for HTML links to the current document
            other_doc.content.include?(current_doc.url)
          )
        end
        
        # Add backlinks to graph data
        docs_linking_to_current.each do |linking_doc|
          # Check if this link already exists (to avoid duplicates)
          existing_link = links.find do |link| 
            link['source'] == linking_doc.basename_without_ext && 
            link['target'] == current_doc.basename_without_ext
          end
          
          # Only add if the link doesn't already exist
          unless existing_link
            links << {
              'source' => linking_doc.basename_without_ext,
              'target' => current_doc.basename_without_ext,
              'type' => current_doc.collection.label
            }
          end
        end
        
        # Store backlinks in document data for use in templates
        current_doc.data['backlinks'] = docs_linking_to_current
      end
      
      # Debug output for links
      puts "Links before creating graph data:"
      links.each_with_index do |link, index|
        puts "  #{index}: #{link.inspect}"
      end
      
      # Create graph data file
      # Make deep copies of the nodes and links arrays to avoid any modifications
      nodes_copy = nodes.map { |node| node.dup }
      links_copy = links.map { |link| link.dup }
      
      # Debug output for nodes
      puts "Nodes before creating graph data:"
      nodes.each_with_index do |node, index|
        puts "  #{index}: #{node.inspect}"
      end
      
      graph_data = {
        'nodes' => nodes_copy,
        'links' => links_copy
      }
      
      # Debug output
      puts "Generating graph data with #{nodes.length} nodes and #{links.length} links"
      puts "Writing graph data to #{File.join(site.dest, 'graph-data.json')}"
      
      # Debug output for graph data
      puts "Graph data before writing to file:"
      puts "  Nodes: #{graph_data['nodes'].length}"
      puts "  Links: #{graph_data['links'].length}"
      
      # Write graph data directly to both the destination and source directories
      graph_data_path = File.join(site.dest, 'graph-data.json')
      graph_data_source_path = File.join(site.source, 'graph-data.json')
      FileUtils.mkdir_p(site.dest) unless File.directory?(site.dest)
      begin
        # Convert to JSON
        json_data = JSON.pretty_generate(graph_data)
        
        # Debug output for JSON data
        puts "JSON data length: #{json_data.length}"
        
        # Write to destination file
        File.write(graph_data_path, json_data)
        puts "Graph data written successfully to #{graph_data_path}"
        puts "File exists in dest: #{File.exist?(graph_data_path)}"
        
        # Also write to source directory as a fallback
        File.write(graph_data_source_path, json_data)
        puts "Graph data also written to #{graph_data_source_path}"
        puts "File exists in source: #{File.exist?(graph_data_source_path)}"
        
        # Read the file back to verify
        file_content = File.read(graph_data_path)
        file_data = JSON.parse(file_content)
        puts "File data after reading back:"
        puts "  Nodes: #{file_data['nodes'].length}"
        puts "  Links: #{file_data['links'].length}"
      rescue => e
        puts "Error writing graph data: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
