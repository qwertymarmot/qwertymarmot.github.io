/**
 * Search functionality for Jekyll Garden
 * Provides client-side search using Lunr.js
 */

document.addEventListener('DOMContentLoaded', function() {
  // Check if search is enabled
  const searchInput = document.getElementById('search-input');
  const searchResults = document.getElementById('search-results');
  
  if (!searchInput || !searchResults) return;
  
  // Load the search index
  const loadSearchIndex = async () => {
    try {
      const response = await fetch('/search-index.json');
      if (!response.ok) {
        throw new Error('Failed to load search index');
      }
      return await response.json();
    } catch (error) {
      console.error('Error loading search index:', error);
      return { documents: [] };
    }
  };
  
  // Initialize lunr.js search
  const initializeSearch = async () => {
    const searchIndex = await loadSearchIndex();
    
    if (!searchIndex.documents || !searchIndex.documents.length) {
      console.warn('Search index is empty or invalid');
      return;
    }
    
    // Create lunr index
    const idx = lunr(function() {
      this.ref('id');
      this.field('title', { boost: 10 });
      this.field('content');
      this.field('tags', { boost: 5 });
      
      // Add documents to the index
      searchIndex.documents.forEach(doc => {
        this.add({
          id: doc.id,
          title: doc.title,
          content: doc.content,
          tags: doc.tags ? doc.tags.join(' ') : ''
        });
      });
    });
    
    // Function to perform search
    const performSearch = (query) => {
      if (!query || query.trim() === '') {
        hideSearchResults();
        return;
      }
      
      try {
        // Search the index
        const results = idx.search(query);
        
        // Clear previous results
        searchResults.innerHTML = '';
        
        if (results.length === 0) {
          searchResults.innerHTML = '<div class="no-results">No results found</div>';
          searchResults.classList.add('active');
          return;
        }
        
        // Display results
        results.slice(0, 10).forEach(result => {
          const doc = searchIndex.documents.find(d => d.id === result.ref);
          if (!doc) return;
          
          const resultElement = document.createElement('div');
          resultElement.className = 'search-result';
          
          const titleElement = document.createElement('div');
          titleElement.className = 'search-result-title';
          titleElement.textContent = doc.title;
          
          const excerptElement = document.createElement('div');
          excerptElement.className = 'search-result-excerpt';
          
          // Create excerpt from content
          let excerpt = doc.content.substring(0, 150).trim();
          if (doc.content.length > 150) {
            excerpt += '...';
          }
          excerptElement.textContent = excerpt;
          
          resultElement.appendChild(titleElement);
          resultElement.appendChild(excerptElement);
          
          // Add click event to navigate to the result
          resultElement.addEventListener('click', () => {
            window.location.href = doc.url;
          });
          
          searchResults.appendChild(resultElement);
        });
        
        searchResults.classList.add('active');
      } catch (error) {
        console.error('Search error:', error);
        searchResults.innerHTML = '<div class="no-results">Search error. Try a different query.</div>';
        searchResults.classList.add('active');
      }
    };
    
    // Function to hide search results
    const hideSearchResults = () => {
      searchResults.classList.remove('active');
    };
    
    // Add event listeners
    searchInput.addEventListener('input', (e) => {
      performSearch(e.target.value);
    });
    
    searchInput.addEventListener('focus', () => {
      if (searchInput.value.trim() !== '') {
        performSearch(searchInput.value);
      }
    });
    
    // Close search results when clicking outside
    document.addEventListener('click', (e) => {
      if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
        hideSearchResults();
      }
    });
    
    // Handle keyboard navigation
    document.addEventListener('keydown', (e) => {
      // Escape key closes search results
      if (e.key === 'Escape') {
        hideSearchResults();
      }
    });
  };
  
  // Load lunr.js script dynamically
  const loadLunrScript = () => {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'https://unpkg.com/lunr/lunr.js';
      script.onload = resolve;
      script.onerror = reject;
      document.head.appendChild(script);
    });
  };
  
  // Initialize search when lunr.js is loaded
  loadLunrScript()
    .then(initializeSearch)
    .catch(error => console.error('Failed to load lunr.js:', error));
});
