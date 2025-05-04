# Jekyll Garden Generator
# Generates search index and graph data for Jekyll Garden

require 'json'
require 'fileutils'

# Register a hook to copy files after site generation
Jekyll::Hooks.register :site, :post_write do |site|
  puts "Post-write hook executed"
  
  # Copy search-index.json to the destination directory
  search_index_source_path = File.join(site.source, 'search-index.json')
  search_index_dest_path = File.join(site.dest, 'search-index.json')
  
  if File.exist?(search_index_source_path)
    FileUtils.cp(search_index_source_path, search_index_dest_path)
    puts "Copied search-index.json to #{search_index_dest_path}"
    puts "File exists in dest after copy: #{File.exist?(search_index_dest_path)}"
  else
    puts "Source file #{search_index_source_path} does not exist"
  end
  
  # Copy graph-data.json to the destination directory
  graph_data_source_path = File.join(site.source, 'graph-data.json')
  graph_data_dest_path = File.join(site.dest, 'graph-data.json')
  
  if File.exist?(graph_data_source_path)
    FileUtils.cp(graph_data_source_path, graph_data_dest_path)
    puts "Copied graph-data.json to #{graph_data_dest_path}"
    puts "File exists in dest after copy: #{File.exist?(graph_data_dest_path)}"
  else
    puts "Source file #{graph_data_source_path} does not exist"
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
        
        nodes << node
        
        # Find wikilinks in content
        wikilinks = doc.content.scan(/\[\[(.*?)\]\]/)
        
        wikilinks.each do |link|
          link_text = link[0].strip
          
          # Determine target collection
          target_collection = 'notes'
          if link_text.start_with?('Book:')
            target_collection = 'books'
            link_text = link_text[5..-1].strip
          end
          
          # Create slug
          slug = link_text.downcase
            .gsub(/\s+/, '-')
            .gsub(/[^\w\-]/, '')
            .gsub(/-{2,}/, '-')
            .gsub(/^-|-$/, '')
          
          # Add link
          links << {
            'source' => doc.basename_without_ext,
            'target' => slug,
            'type' => target_collection
          }
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
      
      # Create graph data file
      graph_data = {
        'nodes' => nodes,
        'links' => links
      }
      
      # Debug output
      puts "Generating graph data with #{nodes.length} nodes and #{links.length} links"
      puts "Writing graph data to #{File.join(site.dest, 'graph-data.json')}"
      
      # Write graph data directly to the destination directory
      graph_data_path = File.join(site.dest, 'graph-data.json')
      FileUtils.mkdir_p(site.dest) unless File.directory?(site.dest)
      begin
        File.write(graph_data_path, JSON.pretty_generate(graph_data))
        puts "Graph data written successfully to #{graph_data_path}"
        puts "File exists: #{File.exist?(graph_data_path)}"
      rescue => e
        puts "Error writing graph data: #{e.message}"
        puts e.backtrace.join("\n")
      end
    end
  end
end
