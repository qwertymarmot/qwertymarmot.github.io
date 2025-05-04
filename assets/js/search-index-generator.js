/**
 * Client-side search index generator for Jekyll Garden
 * Generates search index on the fly
 */

document.addEventListener('DOMContentLoaded', function() {
  // Only run this script once to generate the search index
  if (localStorage.getItem('searchIndexGenerated')) return;
  
  // Function to fetch all notes and books
  const fetchAllDocuments = async () => {
    try {
      const siteRoot = document.querySelector('meta[name="site-root"]')?.getAttribute('content') || '';
      
      // Fetch notes
      const notesResponse = await fetch(`${siteRoot}/notes.html`);
      if (!notesResponse.ok) throw new Error('Failed to fetch notes');
      const notesHtml = await notesResponse.text();
      
      // Fetch books
      const booksResponse = await fetch(`${siteRoot}/books.html`);
      if (!booksResponse.ok) throw new Error('Failed to fetch books');
      const booksHtml = await booksResponse.text();
      
      // Parse notes
      const notesLinks = [...new DOMParser().parseFromString(notesHtml, 'text/html')
        .querySelectorAll('.note-card a[href^="/notes/"]')];
      
      // Parse books
      const booksLinks = [...new DOMParser().parseFromString(booksHtml, 'text/html')
        .querySelectorAll('.book-card a[href^="/books/"]')];
      
      // Combine all links
      const allLinks = [...notesLinks, ...booksLinks];
      
      // Fetch each document
      const documents = [];
      
      for (const link of allLinks) {
        const url = link.getAttribute('href');
        const title = link.textContent.trim();
        const id = url.split('/').pop();
        const type = url.includes('/books/') ? 'book' : 'note';
        
        try {
          const response = await fetch(`${siteRoot}${url}`);
          if (!response.ok) continue;
          
          const html = await response.text();
          const doc = new DOMParser().parseFromString(html, 'text/html');
          
          // Extract content
          const contentElement = doc.querySelector(type === 'book' ? '.book-notes' : '.note-content');
          if (!contentElement) continue;
          
          const content = contentElement.textContent.replace(/\s+/g, ' ').trim();
          
          // Extract tags
          const tagsElements = doc.querySelectorAll(`.${type}-tag`);
          const tags = [...tagsElements].map(el => el.textContent.trim());
          
          // Extract date
          const dateElement = doc.querySelector(`.${type}-date`);
          const date = dateElement ? dateElement.textContent.trim() : '';
          
          documents.push({
            id,
            title,
            content,
            url,
            tags,
            type,
            date
          });
        } catch (error) {
          console.error(`Error fetching ${url}:`, error);
        }
      }
      
      return documents;
    } catch (error) {
      console.error('Error fetching documents:', error);
      return [];
    }
  };
  
  // Generate and save search index
  const generateSearchIndex = async () => {
    try {
      const documents = await fetchAllDocuments();
      
      if (documents.length === 0) {
        console.error('No documents found');
        return;
      }
      
      const searchIndex = { documents };
      
      // Save to localStorage for debugging
      localStorage.setItem('searchIndex', JSON.stringify(searchIndex));
      localStorage.setItem('searchIndexGenerated', 'true');
      
      console.log(`Search index generated with ${documents.length} documents`);
      
      // Dispatch event to notify that search index is ready
      document.dispatchEvent(new CustomEvent('searchIndexReady', { detail: searchIndex }));
    } catch (error) {
      console.error('Error generating search index:', error);
    }
  };
  
  // Generate search index
  generateSearchIndex();
});
