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
      
      # Add notes to graph data
      site.collections['notes']&.docs&.each do |note|
        next if note.data['exclude_from_graph']
        
        # Create node
        node = {
          'id' => note.basename_without_ext,
          'title' => note.data['title'] || note.basename_without_ext.tr('-', ' ').capitalize,
          'url' => note.url,
          'type' => note.data['type'] || 'evergreen'
        }
        
        # Add excerpt if available
        if note.content.length > 150
          node['excerpt'] = note.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip[0...150] + '...'
        else
          node['excerpt'] = note.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip
        end
        
        nodes << node
        
        # Find links in content
        wikilinks = note.content.scan(/\[\[(.*?)\]\]/)
        
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
            'source' => note.basename_without_ext,
            'target' => slug,
            'type' => target_collection
          }
        end
      end
      
      # Add books to graph data
      site.collections['books']&.docs&.each do |book|
        next if book.data['exclude_from_graph']
        
        # Create node
        node = {
          'id' => book.basename_without_ext,
          'title' => book.data['title'] || book.basename_without_ext.tr('-', ' ').capitalize,
          'url' => book.url,
          'type' => 'book'
        }
        
        # Add excerpt if available
        if book.content.length > 150
          node['excerpt'] = book.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip[0...150] + '...'
        else
          node['excerpt'] = book.content.gsub(/<[^>]*>/, ' ').gsub(/\s+/, ' ').strip
        end
        
        nodes << node
        
        # Find links in content
        wikilinks = book.content.scan(/\[\[(.*?)\]\]/)
        
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
            'source' => book.basename_without_ext,
            'target' => slug,
            'type' => target_collection
          }
        end
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
