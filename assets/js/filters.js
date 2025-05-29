/**
 * Filtering functionality for Jekyll Garden
 * Handles filtering notes by type and tags
 */

document.addEventListener('DOMContentLoaded', function() {
  // Get filter elements
  const filterButtons = document.querySelectorAll('.filter-btn');
  const noteCards = document.querySelectorAll('.note-card');
  
  if (!filterButtons.length || !noteCards.length) return;
  
  // Track active filters
  const activeFilters = {
    category: 'all',
    type: 'all',
    tag: 'all'
  };

  // Initially hide all notes except the first 9
  noteCards.forEach((card, index) => {
    if (index >= 9) {
      card.style.display = 'none';
    }
  });
  
  // Add click event listeners to filter buttons
  filterButtons.forEach(button => {
    button.addEventListener('click', function() {
      // Get filter group (category, type, or tag)
      const filterGroup = this.closest('.filter-group');
      const filterLabel = filterGroup.querySelector('label').textContent.toLowerCase();
      let filterType;
      
      if (filterLabel.includes('category')) {
        filterType = 'category';
      } else if (filterLabel.includes('type')) {
        filterType = 'type';
      } else if (filterLabel.includes('tag')) {
        filterType = 'tag';
      }
      
      // Update active button in this group
      filterGroup.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
      });
      this.classList.add('active');
      
      // Update active filter
      if (this.hasAttribute('data-filter-category')) {
        activeFilters.category = this.getAttribute('data-filter-category');
      } else if (this.hasAttribute('data-filter-type')) {
        activeFilters.type = this.getAttribute('data-filter-type');
      } else if (this.hasAttribute('data-filter-tag')) {
        activeFilters.tag = this.getAttribute('data-filter-tag');
      } else if (this.hasAttribute('data-filter')) {
        activeFilters[filterType] = this.getAttribute('data-filter');
      }
      
      // Apply filters
      applyFilters();
    });
  });
  
  // Apply filters to note cards
  function applyFilters() {
    // Show all cards first
    noteCards.forEach(card => {
      card.style.display = '';
    });

    // Filter the cards
    noteCards.forEach(card => {
      const cardType = card.getAttribute('data-type');
      const cardCategory = card.getAttribute('data-category') || '';
      const cardTags = card.getAttribute('data-tags') ? card.getAttribute('data-tags').split(',') : [];
      
      // Check if card matches category filter
      const matchesCategory = activeFilters.category === 'all' || cardCategory === activeFilters.category;
      
      // Check if card matches type filter
      const matchesType = activeFilters.type === 'all' || cardType === activeFilters.type;
      
      // Check if card matches tag filter
      const matchesTag = activeFilters.tag === 'all' || cardTags.includes(activeFilters.tag);
      
      // Show/hide card based on filters
      if (matchesCategory && matchesType && matchesTag) {
        card.style.display = '';
      } else {
        card.style.display = 'none';
      }
    });
    
    // Check if any cards are visible
    const visibleCards = Array.from(noteCards).filter(card => card.style.display !== 'none');
    
    // Show/hide no results message
    let noResultsMessage = document.querySelector('.no-filter-results');
    
    if (visibleCards.length === 0) {
      if (!noResultsMessage) {
        noResultsMessage = document.createElement('div');
        noResultsMessage.className = 'no-filter-results';
        noResultsMessage.textContent = 'No notes match the selected filters';
        document.querySelector('.notes-grid').appendChild(noResultsMessage);
      }
      noResultsMessage.style.display = '';
    } else if (noResultsMessage) {
      noResultsMessage.style.display = 'none';
    }
  }
});
