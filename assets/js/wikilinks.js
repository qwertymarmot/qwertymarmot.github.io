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
    
    // Get all book slugs for reference
    const bookLinks = document.querySelectorAll('a[href^="/books/"]');
    const bookSlugs = new Set();
    bookLinks.forEach(link => {
      const href = link.getAttribute('href');
      const slug = href.split('/').pop();
      if (slug) bookSlugs.add(slug);
    });
    
    contentAreas.forEach(content => {
      // Find all wikilinks in the content that are not inside code blocks
      const html = content.innerHTML;
      
      // Process wikilinks outside of code blocks
      let processedHtml = html;
      
      // First, temporarily replace code blocks with placeholders
      const codeBlocks = [];
      processedHtml = processedHtml.replace(/<pre><code[\s\S]*?<\/code><\/pre>/g, (match) => {
        const placeholder = `CODE_BLOCK_${codeBlocks.length}`;
        codeBlocks.push(match);
        return placeholder;
      });
      
      // Then, process wikilinks
      const wikilinksRegex = /\[\[(.*?)\]\]/g;
      processedHtml = processedHtml.replace(wikilinksRegex, (match, linkText) => {
        // Extract the link text
        linkText = linkText.trim();
        
        // Determine the collection (notes by default)
        let collection = 'notes';
        let displayText = linkText;
        
        // Check if the link is to a book
        if (linkText.startsWith('Book:')) {
          collection = 'books';
          displayText = linkText.substring(5).trim(); // Remove the "Book:" prefix for display
        } else if (linkText.startsWith('Book: ')) {
          collection = 'books';
          displayText = linkText.substring(6).trim(); // Remove the "Book: " prefix with space for display
        } else {
          // Check if a book with this name exists
          const bookSlug = displayText.toLowerCase()
            .replace(/\s+/g, '-')           // Replace spaces with hyphens
            .replace(/[^\w\-]+/g, '')       // Remove non-word chars
            .replace(/\-\-+/g, '-')         // Replace multiple hyphens with single hyphen
            .replace(/^-+/, '')             // Trim hyphens from start
            .replace(/-+$/, '');            // Trim hyphens from end
          
          // Check if this slug exists in our book slugs set
          if (bookSlugs.has(bookSlug)) {
            collection = 'books';
          }
        }
        
        // Create a URL-friendly slug from the display text (without the Book: prefix if it's a book)
        const slug = displayText.toLowerCase()
          .replace(/\s+/g, '-')           // Replace spaces with hyphens
          .replace(/[^\w\-]+/g, '')       // Remove non-word chars
          .replace(/\-\-+/g, '-')         // Replace multiple hyphens with single hyphen
          .replace(/^-+/, '')             // Trim hyphens from start
          .replace(/-+$/, '');            // Trim hyphens from end
        
        // Create the link
        return `<a href="/${collection}/${slug}" class="wikilink" data-link-type="${collection}">${displayText}</a>`;
      });
      
      // Finally, restore code blocks
      codeBlocks.forEach((block, index) => {
        processedHtml = processedHtml.replace(`CODE_BLOCK_${index}`, block);
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
