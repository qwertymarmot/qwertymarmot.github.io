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
    type: 'all',
    tag: 'all'
  };
  
  // Add click event listeners to filter buttons
  filterButtons.forEach(button => {
    button.addEventListener('click', function() {
      // Get filter group (type or tag)
      const filterGroup = this.closest('.filter-group');
      const isTagFilter = filterGroup.querySelector('.tags-filter') !== null;
      const filterType = isTagFilter ? 'tag' : 'type';
      
      // Update active button in this group
      filterGroup.querySelectorAll('.filter-btn').forEach(btn => {
        btn.classList.remove('active');
      });
      this.classList.add('active');
      
      // Update active filter
      activeFilters[filterType] = this.getAttribute('data-filter');
      
      // Apply filters
      applyFilters();
    });
  });
  
  // Apply filters to note cards
  function applyFilters() {
    noteCards.forEach(card => {
      const cardType = card.getAttribute('data-type');
      const cardTags = card.getAttribute('data-tags').split(',');
      
      // Check if card matches type filter
      const matchesType = activeFilters.type === 'all' || cardType === activeFilters.type;
      
      // Check if card matches tag filter
      const matchesTag = activeFilters.tag === 'all' || cardTags.includes(activeFilters.tag);
      
      // Show/hide card based on filters
      if (matchesType && matchesTag) {
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
