(function() {
  window.generate_graph = function(data, modulus, lines) {
    var h, lineFunction, r, svg, w, xScale, yScale;
    w = 600;
    h = 400;
    r = 2;
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
      return d[0];
    }).y(function(d) {
      return d[1];
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
      return svg.selectAll("path").data(lines).enter().append("path");
    }
  };

}).call(this);
