# frozen_string_literal: true

class BidirectionalLinksGenerator < Jekyll::Generator
  def generate(site)
    graph_nodes = []
    graph_edges = []

    all_notes = site.collections['notes'].docs
    all_books = site.collections['books'].docs
    all_pages = site.pages

    all_docs = all_notes + all_books + all_pages

    link_extension = !!site.config["use_html_extension"] ? '.html' : ''

    # Convert all Wiki/Roam-style double-bracket link syntax to plain HTML
    # anchor tag elements (<a>) with "internal-link" CSS class
    all_docs.each do |current_note|
      all_docs.each do |note_potentially_linked_to|
        note_title_regexp_pattern = Regexp.escape(
          File.basename(
            note_potentially_linked_to.basename,
            File.extname(note_potentially_linked_to.basename)
          )
        ).gsub('\_', '[ _]').gsub('\-', '[ -]').capitalize

        title_from_data = note_potentially_linked_to.data['title']
        if title_from_data
          title_from_data = Regexp.escape(title_from_data)
        end

        new_href = "#{site.baseurl}#{note_potentially_linked_to.url}#{link_extension}"
        anchor_tag = "<a class='internal-link' href='#{new_href}'>\\1</a>"

        # Replace double-bracketed links with label using note title
        # [[A note about cats|this is a link to the note about cats]]
        current_note.content.gsub!(
          /\[\[#{note_title_regexp_pattern}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links with label using note filename
        # [[cats|this is a link to the note about cats]]
        current_note.content.gsub!(
          /\[\[#{title_from_data}\|(.+?)(?=\])\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links using note title
        # [[a note about cats]]
        current_note.content.gsub!(
          /\[\[(#{title_from_data})\]\]/i,
          anchor_tag
        )

        # Replace double-bracketed links using note filename
        # [[cats]]
        current_note.content.gsub!(
          /\[\[(#{note_title_regexp_pattern})\]\]/i,
          anchor_tag
        )
        
        # Handle "Book:" prefix for book links
        # [[Book: How to Take Smart Notes]]
        if note_potentially_linked_to.collection.label == 'books'
          book_title = note_potentially_linked_to.data['title']
          current_note.content.gsub!(
            /\[\[Book: #{Regexp.escape(book_title)}\]\]/i,
            anchor_tag
          )
          current_note.content.gsub!(
            /\[\[Book:#{Regexp.escape(book_title)}\]\]/i,
            anchor_tag
          )
        end
      end

      # At this point, all remaining double-bracket-wrapped words are
      # pointing to non-existing pages, so let's turn them into disabled
      # links by greying them out and changing the cursor
      current_note.content = current_note.content.gsub(
        /\[\[([^\]]+)\]\]/i, # match on the remaining double-bracket links
        <<~HTML.delete("\n") # replace with this HTML (\\1 is what was inside the brackets)
          <span title='There is no note that matches this link.' class='invalid-link'>
            <span class='invalid-link-brackets'>[[</span>
            \\1
            <span class='invalid-link-brackets'>]]</span></span>
        HTML
      )
    end

    # Identify note backlinks and add them to each note
    all_notes.each do |current_note|
      # Nodes: Jekyll
      notes_linking_to_current_note = all_notes.filter do |e|
        e.url != current_note.url && (
          e.content.include?(current_note.url) || 
          e.content.include?("[[#{current_note.data['title']}]]") ||
          e.content.include?("[[#{current_note.basename_without_ext.tr('-', ' ').capitalize}]]")
        )
      end

      books_linking_to_current_note = all_books.filter do |e|
        e.content.include?(current_note.url) || 
        e.content.include?("[[#{current_note.data['title']}]]") ||
        e.content.include?("[[#{current_note.basename_without_ext.tr('-', ' ').capitalize}]]")
      end

      # Nodes: Graph
      graph_nodes << {
        id: note_id_from_note(current_note),
        path: "#{site.baseurl}#{current_note.url}#{link_extension}",
        label: current_note.data['title'],
      } unless current_note.path.include?('_notes/index.html')

      # Edges: Jekyll
      current_note.data['backlinks'] = notes_linking_to_current_note + books_linking_to_current_note

      # Edges: Graph
      notes_linking_to_current_note.each do |n|
        graph_edges << {
          source: note_id_from_note(n),
          target: note_id_from_note(current_note),
        }
      end

      books_linking_to_current_note.each do |b|
        graph_edges << {
          source: note_id_from_note(b),
          target: note_id_from_note(current_note),
        }
      end
    end

    # Identify book backlinks and add them to each book
    all_books.each do |current_book|
      # Nodes: Jekyll
      notes_linking_to_current_book = all_notes.filter do |e|
        e.content.include?(current_book.url) || 
        e.content.include?("[[#{current_book.data['title']}]]") ||
        e.content.include?("[[Book: #{current_book.data['title']}]]") ||
        e.content.include?("[[Book:#{current_book.data['title']}]]") ||
        e.content.include?("[[#{current_book.basename_without_ext.tr('-', ' ').capitalize}]]")
      end

      books_linking_to_current_book = all_books.filter do |e|
        e.url != current_book.url && (
          e.content.include?(current_book.url) || 
          e.content.include?("[[#{current_book.data['title']}]]") ||
          e.content.include?("[[Book: #{current_book.data['title']}]]") ||
          e.content.include?("[[Book:#{current_book.data['title']}]]") ||
          e.content.include?("[[#{current_book.basename_without_ext.tr('-', ' ').capitalize}]]")
        )
      end

      # Nodes: Graph
      graph_nodes << {
        id: note_id_from_note(current_book),
        path: "#{site.baseurl}#{current_book.url}#{link_extension}",
        label: current_book.data['title'],
      } unless current_book.path.include?('_books/index.html')

      # Edges: Jekyll
      current_book.data['backlinks'] = notes_linking_to_current_book + books_linking_to_current_book

      # Edges: Graph
      notes_linking_to_current_book.each do |n|
        graph_edges << {
          source: note_id_from_note(n),
          target: note_id_from_note(current_book),
        }
      end

      books_linking_to_current_book.each do |b|
        graph_edges << {
          source: note_id_from_note(b),
          target: note_id_from_note(current_book),
        }
      end
    end

    # Write to multiple locations for compatibility
    
    # 1. _includes/notes_graph.json for direct inclusion in templates
    includes_dir = File.join(site.source, '_includes')
    Dir.mkdir(includes_dir) unless Dir.exist?(includes_dir)
    
    File.write(File.join(includes_dir, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
    
    # 2. Root notes_graph.json for JavaScript to fetch
    File.write(File.join(site.source, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
    
    # 3. assets/js/notes_graph.json as a fallback location
    assets_js_dir = File.join(site.source, 'assets', 'js')
    Dir.mkdir(File.join(site.source, 'assets')) unless Dir.exist?(File.join(site.source, 'assets'))
    Dir.mkdir(assets_js_dir) unless Dir.exist?(assets_js_dir)
    
    File.write(File.join(assets_js_dir, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
    
    # 4. Also write to the _site directory for GitHub Pages
    site_dir = File.join(site.dest)
    site_includes_dir = File.join(site_dir, '_includes')
    site_assets_js_dir = File.join(site_dir, 'assets', 'js')
    
    # Create directories if they don't exist
    Dir.mkdir(site_dir) unless Dir.exist?(site_dir)
    Dir.mkdir(site_includes_dir) unless Dir.exist?(site_includes_dir)
    Dir.mkdir(File.join(site_dir, 'assets')) unless Dir.exist?(File.join(site_dir, 'assets'))
    Dir.mkdir(site_assets_js_dir) unless Dir.exist?(site_assets_js_dir)
    
    # Write to _site directory
    File.write(File.join(site_dir, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
    
    File.write(File.join(site_includes_dir, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
    
    File.write(File.join(site_assets_js_dir, 'notes_graph.json'), JSON.dump({
      edges: graph_edges,
      nodes: graph_nodes,
    }))
  end

  def note_id_from_note(note)
    note.data['title'].bytes.join
  end
end
