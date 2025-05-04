# Jekyll Garden Search Index Generator
# Generates search index for Jekyll Garden
# Based on the jekyll_garden_generator.rb

require 'json'

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
  end
end
