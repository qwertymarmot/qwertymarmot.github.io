/**
 * Notes Graph Visualization
 * Based on the approach from digital-garden-jekyll-template by Maxime Vaillancourt
 * https://github.com/maximevaillancourt/digital-garden-jekyll-template
 */

(function() {
  const MINIMAL_NODE_SIZE = 8;
  const MAX_NODE_SIZE = 12;
  const ACTIVE_RADIUS_FACTOR = 1.5;
  const STROKE = 1;
  const FONT_SIZE = 16;
  const TICKS = 200;
  const FONT_BASELINE = 40;
  const MAX_LABEL_LENGTH = 50;

  // Create a default graph data structure with empty nodes and edges
  const defaultGraphData = {
    nodes: [],
    edges: []
  };

  // Load graph data from the JSON file, trying multiple locations
  // Get the baseurl from the meta tag
  const baseurl = document.querySelector('meta[name="baseurl"]')?.getAttribute('content') || '';
  
  fetch(baseurl + '/notes_graph.json')
    .catch(() => fetch(baseurl + '/assets/js/notes_graph.json'))
    .catch(() => fetch(baseurl + '/_includes/notes_graph.json'))
    .catch(() => {
      console.warn("Could not load graph data from any location, using empty graph");
      return new Response(JSON.stringify(defaultGraphData));
    })
    .then(response => response.json())
    .then(data => {
      const nodesData = data.nodes;
      const linksData = data.edges;
      
      const nodeSize = {};

      const updateNodeSize = () => {
        nodesData.forEach((el) => {
          let weight =
            3 *
            Math.sqrt(
              linksData.filter((l) => l.source === el.id || l.target === el.id)
                .length + 1
            );
          if (weight < MINIMAL_NODE_SIZE) {
            weight = MINIMAL_NODE_SIZE;
          } else if (weight > MAX_NODE_SIZE) {
            weight = MAX_NODE_SIZE;
          }
          nodeSize[el.id] = weight;
        });
      };

      const onClick = (d) => {
        window.location = d.path;
      };

      const onMouseover = function (d) {
        const relatedNodesSet = new Set();
        linksData
          .filter((n) => n.target === d.id || n.source === d.id)
          .forEach((n) => {
            relatedNodesSet.add(n.target);
            relatedNodesSet.add(n.source);
          });

        node.attr("class", (node_d) => {
          if (node_d.id !== d.id && !relatedNodesSet.has(node_d.id)) {
            return "inactive";
          }
          return "";
        });

        link.attr("class", (link_d) => {
          if (link_d.source !== d.id && link_d.target !== d.id) {
            return "inactive";
          }
          return "";
        });

        link.attr("stroke-width", (link_d) => {
          if (link_d.source === d.id || link_d.target === d.id) {
            return STROKE * 4;
          }
          return STROKE;
        });
        
        text.attr("class", (text_d) => {
          if (text_d.id !== d.id && !relatedNodesSet.has(text_d.id)) {
            return "inactive";
          }
          return "";
        });
      };

      const onMouseout = function (d) {
        node.attr("class", "");
        link.attr("class", "");
        text.attr("class", "");
        link.attr("stroke-width", STROKE);
      };

      const graphWrapper = document.getElementById('graph-wrapper');
      
      // Add CSS styles
      const style = document.createElement('style');
      style.textContent = `
        .links line {
          stroke: #ccc;
          opacity: 0.5;
        }
        
        .nodes circle {
          cursor: pointer;
          fill: #8b88e6;
          transition: all 0.15s ease-out;
        }
        
        .text text {
          cursor: pointer;
          fill: #333;
          text-shadow: -1px -1px 0 #fafafabb, 1px -1px 0 #fafafabb, -1px 1px 0 #fafafabb, 1px 1px 0 #fafafabb;
        }
        
        .nodes [active],
        .text [active] {
          cursor: pointer;
          fill: black;
        }
        
        .inactive {
          opacity: 0.1;
          transition: all 0.15s ease-out;
        }
        
        #graph-wrapper {
          background: #fcfcfc;
          border-radius: 4px;
          height: 500px;
        }
        
        #graph-wrapper > svg {
          max-width: 100%;
          display: block;
        }
      `;
      document.head.appendChild(style);
      
      const element = document.createElementNS("http://www.w3.org/2000/svg", "svg");
      element.setAttribute("width", graphWrapper.getBoundingClientRect().width);
      element.setAttribute("height", 500);
      graphWrapper.appendChild(element);

      const reportWindowSize = () => {
        element.setAttribute("width", graphWrapper.getBoundingClientRect().width);
      };

      window.addEventListener('resize', reportWindowSize);

      const svg = d3.select("svg");
      const width = Number(svg.attr("width"));
      const height = Number(svg.attr("height"));
      let zoomLevel = 1;

      const simulation = d3
        .forceSimulation(nodesData)
        .force("forceX", d3.forceX().x(width / 2))
        .force("forceY", d3.forceY().y(height / 2))
        .force("charge", d3.forceManyBody())
        .force(
          "link",
          d3
            .forceLink(linksData)
            .id((d) => d.id)
            .distance(70)
        )
        .force("center", d3.forceCenter(width / 2, height / 2))
        .force("collision", d3.forceCollide().radius(80))
        .stop();

      const g = svg.append("g");
      let link = g.append("g").attr("class", "links").selectAll(".link");
      let node = g.append("g").attr("class", "nodes").selectAll(".node");
      let text = g.append("g").attr("class", "text").selectAll(".text");

      const resize = () => {
        if (d3.event) {
          const scale = d3.event.transform;
          zoomLevel = scale.k;
          g.attr("transform", scale);
        }

        const zoomOrKeep = (value) => (zoomLevel >= 1 ? value / zoomLevel : value);

        const font = Math.max(Math.round(zoomOrKeep(FONT_SIZE)), 1);

        text.attr("font-size", (d) => font);
        text.attr("y", (d) => d.y - zoomOrKeep(FONT_BASELINE) + 8);
        link.attr("stroke-width", zoomOrKeep(STROKE));
        node.attr("r", (d) => {
          return zoomOrKeep(nodeSize[d.id]);
        });
        svg
          .selectAll("circle")
          .filter((_d, i, nodes) => d3.select(nodes[i]).attr("active"))
          .attr("r", (d) => zoomOrKeep(ACTIVE_RADIUS_FACTOR * nodeSize[d.id]));
      };

      const ticked = () => {
        node.attr("cx", (d) => d.x).attr("cy", (d) => d.y);
        text
          .attr("x", (d) => d.x)
          .attr("y", (d) => d.y - (FONT_BASELINE - nodeSize[d.id]) / zoomLevel);
        link
          .attr("x1", (d) => d.source.x)
          .attr("y1", (d) => d.source.y)
          .attr("x2", (d) => d.target.x)
          .attr("y2", (d) => d.target.y);
      };

      const restart = () => {
        updateNodeSize();
        node = node.data(nodesData, (d) => d.id);
        node.exit().remove();
        node = node
          .enter()
          .append("circle")
          .attr("r", (d) => {
            return nodeSize[d.id];
          })
          .on("click", onClick)
          .on("mouseover", onMouseover)
          .on("mouseout", onMouseout)
          .merge(node);

        link = link.data(linksData, (d) => `${d.source}-${d.target}`);
        link.exit().remove();
        link = link.enter().append("line").attr("stroke-width", STROKE).merge(link);

        text = text.data(nodesData, (d) => d.id);
        text.exit().remove();
        text = text
          .enter()
          .append("text")
          .text((d) => shorten(d.label.replace(/_*/g, ""), MAX_LABEL_LENGTH))
          .attr("font-size", `${FONT_SIZE}px`)
          .attr("text-anchor", "middle")
          .attr("alignment-baseline", "central")
          .on("click", onClick)
          .on("mouseover", onMouseover)
          .on("mouseout", onMouseout)
          .merge(text);

        node.attr("active", (d) => isCurrentPath(d.path) ? true : null);
        text.attr("active", (d) => isCurrentPath(d.path) ? true : null);

        simulation.nodes(nodesData);
        simulation.force("link").links(linksData);
        simulation.alpha(1).restart();
        simulation.stop();

        for (let i = 0; i < TICKS; i++) {
          simulation.tick();
        }

        ticked();
      };

      const zoomHandler = d3.zoom().scaleExtent([0.2, 3]).on("zoom", resize);

      zoomHandler(svg);
      restart();

      function isCurrentPath(notePath) {
        return window.location.pathname.includes(notePath);
      }

      function shorten(str, maxLen, separator = ' ') {
        if (str.length <= maxLen) return str;
        return str.substr(0, str.lastIndexOf(separator, maxLen)) + '...';
      }
    })
    .catch(error => {
      console.error("Error loading the graph data:", error);
      document.getElementById('graph-wrapper').innerHTML = '<p>Error loading the graph data</p>';
    });
})();
