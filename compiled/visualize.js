(function() {
  var expand_line_object;

  expand_line_object = function(data, lines) {
    var array, center, center_index, center_node, node_array, val, value_index, value_node, _i, _len;
    node_array = [];
    for (center in lines) {
      array = lines[center];
      for (_i = 0, _len = array.length; _i < _len; _i++) {
        val = array[_i];
        center_index = parseInt(center);
        value_index = parseInt(val);
        center_node = data[center_index];
        value_node = data[value_index];
        node_array.push([center_node, value_node]);
      }
    }
    return node_array;
  };

  window.generate_graph = function(data, modulus, lines) {
    var expanded_lines, h, lineFunction, r, svg, w, xScale, yScale;
    w = 600;
    h = 400;
    r = 3;
    svg = d3.select("#container").append("svg").attr("width", w).attr("height", h);
    xScale = d3.scale.linear().domain([
      d3.min(data, function(d) {
        return d[0];
      }), d3.max(data, function(d) {
        return d[0];
      })
    ]).range([0 + (r + 5), w - (r + 5)]);
    yScale = d3.scale.linear().domain([
      d3.min(data, function(d) {
        return d[1];
      }), d3.max(data, function(d) {
        return d[1];
      })
    ]).range([0 + (r + 5), h - (r + 5)]);
    lineFunction = d3.svg.line().x(function(d) {
      return xScale(d[0]);
    }).y(function(d) {
      return yScale(d[1]);
    }).interpolate("linear");
    svg.selectAll("circle").data(data).enter().append("circle").style("stroke", "black").style("fill", function(d, i) {
      if (i % modulus === 0) {
        return "red";
      } else {
        return "black";
      }
    }).attr("r", r).attr("cx", function(d) {
      return xScale(d[0]);
    }).attr("cy", function(d) {
      return yScale(d[1]);
    });
    if (lines !== null) {
      expanded_lines = expand_line_object(data, lines);
      return svg.selectAll("path").data(expanded_lines).enter().append("path").attr("d", function(array) {
        return lineFunction(array);
      }).attr("stroke", "black");
    }
  };

}).call(this);
