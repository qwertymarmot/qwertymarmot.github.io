/**
 * Theme toggle functionality for Jekyll Garden
 * Handles switching between light and dark mode
 */

document.addEventListener('DOMContentLoaded', function() {
  const themeToggleBtn = document.getElementById('theme-toggle-btn');
  
  if (!themeToggleBtn) return;
  
  // Check for saved theme preference or use the system preference
  const getThemePreference = () => {
    const savedTheme = localStorage.getItem('theme');
    if (savedTheme) {
      return savedTheme;
    }
    
    // Check if the user has a system preference
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  };
  
  // Apply the theme
  const applyTheme = (theme) => {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
  };
  
  // Toggle the theme
  const toggleTheme = () => {
    const currentTheme = document.documentElement.getAttribute('data-theme') || 'light';
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    applyTheme(newTheme);
  };
  
  // Initialize theme
  applyTheme(getThemePreference());
  
  // Add event listener to the theme toggle button
  themeToggleBtn.addEventListener('click', toggleTheme);
  
  // Listen for system theme changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (localStorage.getItem('theme')) return; // Don't override user preference
    applyTheme(e.matches ? 'dark' : 'light');
  });
});
