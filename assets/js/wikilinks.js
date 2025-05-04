/**
 * Wikilinks processing for Jekyll Garden
 * Converts [[wikilinks]] to proper HTML links
 */

document.addEventListener('DOMContentLoaded', function() {
  // Process wikilinks in content
  const processWikilinks = () => {
    // Find all content areas that might contain wikilinks
    const contentAreas = document.querySelectorAll('.note-content, .book-notes');
    
    if (!contentAreas.length) return;
    
    contentAreas.forEach(content => {
      // Find all wikilinks in the content
      const wikilinksRegex = /\[\[(.*?)\]\]/g;
      const html = content.innerHTML;
      
      // Replace wikilinks with HTML links
      const processedHtml = html.replace(wikilinksRegex, (match, linkText) => {
        // Extract the link text
        linkText = linkText.trim();
        
        // Create a URL-friendly slug
        const slug = linkText.toLowerCase()
          .replace(/\s+/g, '-')           // Replace spaces with hyphens
          .replace(/[^\w\-]+/g, '')       // Remove non-word chars
          .replace(/\-\-+/g, '-')         // Replace multiple hyphens with single hyphen
          .replace(/^-+/, '')             // Trim hyphens from start
          .replace(/-+$/, '');            // Trim hyphens from end
        
        // Determine the collection (notes by default)
        let collection = 'notes';
        
        // Check if the link is to a book
        if (linkText.startsWith('Book:')) {
          collection = 'books';
          linkText = linkText.substring(5).trim(); // Remove the "Book:" prefix
        } else if (linkText.startsWith('Book: ')) {
          collection = 'books';
          linkText = linkText.substring(6).trim(); // Remove the "Book: " prefix with space
        } else {
          // Check if a book with this name exists
          const bookSlug = linkText.toLowerCase()
            .replace(/\s+/g, '-')
            .replace(/[^\w\-]+/g, '')
            .replace(/\-\-+/g, '-')
            .replace(/^-+/, '')
            .replace(/-+$/, '');
          
          // Look for a book element with this slug
          const bookElement = document.querySelector(`a[href="/books/${bookSlug}"]`);
          if (bookElement) {
            collection = 'books';
          }
        }
        
        // Create the link
        return `<a href="/${collection}/${slug}" class="wikilink">${linkText}</a>`;
      });
      
      // Update the content
      if (html !== processedHtml) {
        content.innerHTML = processedHtml;
      }
    });
  };
  
  // Process wikilinks on page load
  processWikilinks();
  
  // Add event listener for dynamic content changes (if needed)
  document.addEventListener('contentChanged', processWikilinks);
});
