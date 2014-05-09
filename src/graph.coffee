expand_line_object = (data, lines) ->
  node_array = []
  for center, array of lines
    for val in array
      center_index = parseInt(center)
      value_index = parseInt(val)
      center_node = data[center_index]
      value_node = data[value_index]
      node_array.push [center_node, value_node]
  node_array

window.generate_graph = (data, modulus, lines) ->
  w = 600
  h = 400
  r = 3

  svg = d3.select("#container")
    .append("svg")
    .attr("width", w)
    .attr("height", h)

  xScale = d3.scale.linear()
    .domain([d3.min(data, (d) -> d[0]), d3.max(data, (d) -> d[0])])
    .range([0+(r+5), w-(r+5)])

  yScale = d3.scale.linear()
    .domain([d3.min(data, (d) -> d[1]), d3.max(data, (d) -> d[1])])
    .range([0+(r+5), h-(r+5)])

  lineFunction = d3.svg.line()
    .x((d) -> xScale(d[0]))
    .y((d) -> yScale(d[1]))
    .interpolate("linear");

  svg.selectAll("circle")
    .data(data)
    .enter()
    .append("circle")
    .style("stroke", "black")
    .style("fill", (d, i) ->
      if i % modulus == 0
        "red"
      else
        "black"
    )
    .attr("r", r)
    .attr("cx", (d) -> xScale(d[0]))
    .attr("cy", (d) -> yScale(d[1]))

  if lines != null
    expanded_lines = expand_line_object data, lines
    svg.selectAll("path")
      .data(expanded_lines)
      .enter()
      .append("path")
      .attr("d", (array) -> lineFunction(array))
      .attr("stroke", "black")
