# Jekyll Garden Generator
# Generates search index and graph data for Jekyll Garden

require 'json'

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
      
      search_index_file = Jekyll::StaticFile.new(
        site,
        site.source,
        '',
        'search-index.json'
      )
      
      File.write(File.join(site.source, 'search-index.json'), JSON.pretty_generate(search_index))
      site.static_files << search_index_file
      
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
          
          # Determine target collection and prepare display text
          target_collection = 'notes'
          display_text = link_text
          
          # Check if link starts with Book: prefix
          if link_text.start_with?('Book:')
            target_collection = 'books'
            if link_text.start_with?('Book: ')
              display_text = link_text[6..-1].strip  # Remove "Book: " with space
            else
              display_text = link_text[5..-1].strip  # Remove "Book:" without space
            end
          else
            # Check if a book with this name exists
            book_slug = link_text.downcase
              .gsub(/\s+/, '-')
              .gsub(/[^\w\-]/, '')
              .gsub(/-{2,}/, '-')
              .gsub(/^-|-$/, '')
            
            # Look for a book with this slug
            site.collections['books']&.docs&.each do |book|
              if book.basename_without_ext == book_slug
                target_collection = 'books'
                break
              end
            end
          end
          
          # Create slug from the display text (without the Book: prefix if it's a book)
          slug = display_text.downcase
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
      
      graph_data_file = Jekyll::StaticFile.new(
        site,
        site.source,
        '',
        'graph-data.json'
      )
      
      File.write(File.join(site.source, 'graph-data.json'), JSON.pretty_generate(graph_data))
      site.static_files << graph_data_file
    end
  end
end
