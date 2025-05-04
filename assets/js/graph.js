/**
 * Graph Visualization for Jekyll Garden
 * Based on the approach from digital-garden-jekyll-template by Maxime Vaillancourt
 * https://github.com/maximevaillancourt/digital-garden-jekyll-template
 */

document.addEventListener('DOMContentLoaded', function() {
  // Check if graph containers exist
  const graphContainer = document.getElementById('graph-container');
  const noteGraph = document.getElementById('note-graph');
  
  if (!graphContainer && !noteGraph) return;
  
  // Load D3.js
  const loadD3 = () => {
    return new Promise((resolve, reject) => {
      if (window.d3) {
        resolve(window.d3);
        return;
      }
      
      const script = document.createElement('script');
      script.src = 'https://d3js.org/d3.v7.min.js';
      script.onload = () => resolve(window.d3);
      script.onerror = reject;
      document.head.appendChild(script);
    });
  };
  
  // Load the graph data
  const loadGraphData = async () => {
    try {
      // Use site root-relative path to ensure it works with base URL configurations
      const siteRoot = document.querySelector('meta[name="site-root"]')?.getAttribute('content') || '';
      const graphDataPath = `${siteRoot}/graph-data.json`;
      
      console.log('Fetching graph data from:', graphDataPath);
      const response = await fetch(graphDataPath);
      
      if (!response.ok) {
        throw new Error(`Failed to load graph data: ${response.status} ${response.statusText}`);
      }
      return await response.json();
    } catch (error) {
      console.error('Error loading graph data:', error);
      return { nodes: [], links: [] };
    }
  };
  
  // Initialize the main graph visualization
  const initializeMainGraph = async (d3, container) => {
    const data = await loadGraphData();
    
    if (!data.nodes || !data.nodes.length) {
      container.innerHTML = '<div class="no-graph-data">No graph data available</div>';
      return;
    }
    
    // Set up the SVG container
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    const svg = d3.select(container)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', [0, 0, width, height]);
    
    // Create a tooltip
    const tooltip = d3.select(container)
      .append('div')
      .attr('class', 'graph-tooltip')
      .style('position', 'absolute')
      .style('visibility', 'hidden');
    
    // Create a group for the graph
    const g = svg.append('g');
    
    // Create zoom behavior
    const zoom = d3.zoom()
      .scaleExtent([0.1, 4])
      .on('zoom', (event) => {
        g.attr('transform', event.transform);
      });
    
    svg.call(zoom);
    
    // Create the simulation
    const simulation = d3.forceSimulation(data.nodes)
      .force('link', d3.forceLink(data.links).id(d => d.id).distance(100))
      .force('charge', d3.forceManyBody().strength(-300))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(30));
    
    // Create the links
    const link = g.append('g')
      .attr('class', 'links')
      .selectAll('line')
      .data(data.links)
      .enter().append('line')
      .attr('class', d => `link ${d.type || ''}`);
    
    // Create the nodes
    const node = g.append('g')
      .attr('class', 'nodes')
      .selectAll('.node')
      .data(data.nodes)
      .enter().append('g')
      .attr('class', d => `node ${d.type || ''}`)
      .call(d3.drag()
        .on('start', dragstarted)
        .on('drag', dragged)
        .on('end', dragended));
    
    // Add circles to nodes
    node.append('circle')
      .attr('r', d => d.type === 'book' ? 8 : 6)
      .on('mouseover', function(event, d) {
        // Show tooltip
        tooltip
          .html(`
            <div class="tooltip-title">${d.title}</div>
            ${d.type ? `<div class="tooltip-type ${d.type}">${d.type}</div>` : ''}
            ${d.excerpt ? `<div class="tooltip-excerpt">${d.excerpt}</div>` : ''}
          `)
          .style('left', (event.pageX + 10) + 'px')
          .style('top', (event.pageY + 10) + 'px')
          .style('visibility', 'visible')
          .classed('visible', true);
      })
      .on('mouseout', function() {
        // Hide tooltip
        tooltip
          .style('visibility', 'hidden')
          .classed('visible', false);
      })
      .on('click', function(event, d) {
        // Navigate to the node's page
        if (d.url) {
          window.location.href = d.url;
        }
      });
    
    // Add labels to nodes
    node.append('text')
      .text(d => d.title)
      .attr('dy', 15)
      .attr('text-anchor', 'middle');
    
    // Add controls
    const controls = d3.select(container)
      .append('div')
      .attr('class', 'graph-controls');
    
    // Zoom in button
    controls.append('button')
      .attr('class', 'zoom-in')
      .html('➕')
      .on('click', () => {
        svg.transition().call(zoom.scaleBy, 1.3);
      });
    
    // Zoom out button
    controls.append('button')
      .attr('class', 'zoom-out')
      .html('➖')
      .on('click', () => {
        svg.transition().call(zoom.scaleBy, 0.7);
      });
    
    // Reset zoom button
    controls.append('button')
      .attr('class', 'zoom-reset')
      .html('⟲')
      .on('click', () => {
        svg.transition().call(zoom.transform, d3.zoomIdentity);
      });
    
    // Update the simulation on tick
    simulation.on('tick', () => {
      link
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);
      
      node.attr('transform', d => `translate(${d.x},${d.y})`);
    });
    
    // Drag functions
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }
    
    function dragged(event) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
    }
    
    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }
    
    // Handle window resize
    const resizeGraph = () => {
      const newWidth = container.clientWidth;
      const newHeight = container.clientHeight;
      
      svg.attr('width', newWidth)
        .attr('height', newHeight)
        .attr('viewBox', [0, 0, newWidth, newHeight]);
      
      simulation.force('center', d3.forceCenter(newWidth / 2, newHeight / 2));
      simulation.alpha(0.3).restart();
    };
    
    window.addEventListener('resize', resizeGraph);
    
    // Toggle between graph and cards view
    const viewToggleBtns = document.querySelectorAll('.view-toggle-btn');
    if (viewToggleBtns.length) {
      viewToggleBtns.forEach(btn => {
        btn.addEventListener('click', function() {
          const view = this.getAttribute('data-view');
          
          // Update active button
          viewToggleBtns.forEach(b => b.classList.remove('active'));
          this.classList.add('active');
          
          // Show the selected view
          document.querySelectorAll('.cards-view, .graph-view').forEach(v => {
            v.classList.remove('active');
          });
          document.querySelector(`.${view}-view`).classList.add('active');
          
          // Resize graph if it's now visible
          if (view === 'graph') {
            resizeGraph();
          }
        });
      });
    }
  };
  
  // Initialize the note-specific graph
  const initializeNoteGraph = async (d3, container) => {
    // Get the current note ID from the URL
    const path = window.location.pathname;
    const segments = path.split('/').filter(Boolean);
    const collection = segments[segments.length - 2]; // 'notes' or 'books'
    const noteId = segments[segments.length - 1];
    
    if (!noteId) return;
    
    // Load graph data
    const data = await loadGraphData();
    
    if (!data.nodes || !data.nodes.length) {
      container.innerHTML = '<div class="no-graph-data">No graph data available</div>';
      return;
    }
    
    // Filter data to include only the current note and its connections
    const currentNode = data.nodes.find(n => n.id === noteId);
    
    if (!currentNode) {
      container.innerHTML = '<div class="no-graph-data">Note not found in graph data</div>';
      return;
    }
    
    // Find connected nodes
    const connectedLinks = data.links.filter(l => 
      l.source === noteId || (typeof l.source === 'object' && l.source.id === noteId) || 
      l.target === noteId || (typeof l.target === 'object' && l.target.id === noteId)
    );
    
    const connectedNodeIds = new Set();
    connectedLinks.forEach(link => {
      const sourceId = typeof link.source === 'object' ? link.source.id : link.source;
      const targetId = typeof link.target === 'object' ? link.target.id : link.target;
      connectedNodeIds.add(sourceId);
      connectedNodeIds.add(targetId);
    });
    
    const filteredNodes = data.nodes.filter(n => connectedNodeIds.has(n.id));
    
    // Set up the SVG container
    const width = container.clientWidth;
    const height = container.clientHeight;
    
    const svg = d3.select(container)
      .append('svg')
      .attr('width', width)
      .attr('height', height)
      .attr('viewBox', [0, 0, width, height]);
    
    // Create the simulation
    const simulation = d3.forceSimulation(filteredNodes)
      .force('link', d3.forceLink(connectedLinks).id(d => d.id).distance(80))
      .force('charge', d3.forceManyBody().strength(-200))
      .force('center', d3.forceCenter(width / 2, height / 2))
      .force('collision', d3.forceCollide().radius(20));
    
    // Create the links
    const link = svg.append('g')
      .attr('class', 'links')
      .selectAll('line')
      .data(connectedLinks)
      .enter().append('line')
      .attr('class', d => `link ${d.type || ''}`);
    
    // Create the nodes
    const node = svg.append('g')
      .attr('class', 'nodes')
      .selectAll('.node')
      .data(filteredNodes)
      .enter().append('g')
      .attr('class', d => `node ${d.type || ''} ${d.id === noteId ? 'active' : ''}`)
      .call(d3.drag()
        .on('start', dragstarted)
        .on('drag', dragged)
        .on('end', dragended));
    
    // Add circles to nodes
    node.append('circle')
      .attr('r', d => d.id === noteId ? 8 : (d.type === 'book' ? 7 : 5))
      .on('click', function(event, d) {
        // Navigate to the node's page
        if (d.url && d.id !== noteId) {
          window.location.href = d.url;
        }
      });
    
    // Add labels to nodes
    node.append('text')
      .text(d => d.title)
      .attr('dy', 15)
      .attr('text-anchor', 'middle');
    
    // Update the simulation on tick
    simulation.on('tick', () => {
      link
        .attr('x1', d => d.source.x)
        .attr('y1', d => d.source.y)
        .attr('x2', d => d.target.x)
        .attr('y2', d => d.target.y);
      
      node.attr('transform', d => `translate(${d.x},${d.y})`);
    });
    
    // Drag functions
    function dragstarted(event) {
      if (!event.active) simulation.alphaTarget(0.3).restart();
      event.subject.fx = event.subject.x;
      event.subject.fy = event.subject.y;
    }
    
    function dragged(event) {
      event.subject.fx = event.x;
      event.subject.fy = event.y;
    }
    
    function dragended(event) {
      if (!event.active) simulation.alphaTarget(0);
      event.subject.fx = null;
      event.subject.fy = null;
    }
    
    // Handle window resize
    const resizeGraph = () => {
      const newWidth = container.clientWidth;
      const newHeight = container.clientHeight;
      
      svg.attr('width', newWidth)
        .attr('height', newHeight)
        .attr('viewBox', [0, 0, newWidth, newHeight]);
      
      simulation.force('center', d3.forceCenter(newWidth / 2, newHeight / 2));
      simulation.alpha(0.3).restart();
    };
    
    window.addEventListener('resize', resizeGraph);
  };
  
  // Initialize graphs
  loadD3()
    .then(d3 => {
      if (graphContainer) {
        initializeMainGraph(d3, graphContainer);
      }
      
      if (noteGraph) {
        initializeNoteGraph(d3, noteGraph);
      }
    })
    .catch(error => {
      console.error('Failed to load D3.js:', error);
      if (graphContainer) {
        graphContainer.innerHTML = '<div class="error">Failed to load graph visualization</div>';
      }
      if (noteGraph) {
        noteGraph.innerHTML = '<div class="error">Failed to load graph visualization</div>';
      }
    });
});
