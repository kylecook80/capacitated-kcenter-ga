helpers = require './helpers'
Chromosome = require './chromosome'

# Attributes for execution
# - data: A multi-dimensional array that contains the nodes
# - temperature: The starting temperature for the "annealing" process
# - alpha: The rate at which the temperature is decreased
# - beta: The rate at which the number of iterations is increased
# - centers: The number of centers we are searching for
# - capacity: The node capacity of a center
# - loops: The number of iterations to go through before decreasing/increasing alpha/beta
# - time: The time to execute the algorithm
class SA
  constructor: (opts) ->
    helpers.extend @, opts
    @nodes = @data.length

  @perturb: (chromosome) ->
    split_chromosome = chromosome.split("").map (val) -> parseInt val
    centers = Chromosome.get_centers chromosome

    rand = helpers.get_random_int(0, centers.length-1)
    loc = helpers.get_random_int(0, split_chromosome.length-1)

    index = centers[rand]

    # console.log "centers: " + centers
    # console.log "loc: " + loc
    # console.log "index: " + index
    # console.log ""

    split_chromosome.splice index, 1
    split_chromosome.splice loc, 0, 1
    split_chromosome.join("")

  @pairwise_switch: (chromosome) ->
    split_chromosome = chromosome.split("").map (val) -> parseInt val
    centers = Chromosome.get_centers chromosome

    loc1 = helpers.get_random_int(0, split_chromosome.length-1)
    loc2 = helpers.get_random_int(0, split_chromosome.length-1)

    val1 = split_chromosome[loc1]
    val2 = split_chromosome[loc2]

    split_chromosome[loc1] = val2
    split_chromosome[loc2] = val1

    split_chromosome.join("")

  # Calculate distance between two nodes given (x,y) pairs
  distance: (src, tgt) ->
    [src_x, src_y] = @data[src]
    [tgt_x, tgt_y] = @data[tgt]
    Math.sqrt (tgt_y-src_y)**2+(tgt_x-src_x)**2 # Distance formula

  get_distance_sum: (obj) ->
    array = for key, array of obj
      for node in array
        @distance(key, node)

    mapped_distances = array.map (sub_array) ->
      sub_array.reduce(((total, next) -> total+next), 0)

    mapped_distances.reduce (total, next) -> total+next

  get_lines: (centers, node_list) ->
    used = []
    edges_per_center = {}

    for array in node_list
      array.sort (a, b) => @distance(a[0], a[1]) - @distance(b[0], b[1])

    for i in centers
      edges_per_center[i] = []

    for nc_node_list in node_list
      for candidate in nc_node_list
        if !helpers.contains(used, candidate[0]) && edges_per_center[candidate[1]].length < @capacity
          edges_per_center[candidate[1]].push candidate[0]
          used.push candidate[0]
        else
          continue

    edges_per_center

  get_node_list: (centers, non_centers) ->
    for nc_node in non_centers
      for c_node in centers
        [nc_node, c_node]

  fitness: (chromosome) ->
    centers = Chromosome.get_centers(chromosome)
    non_centers = Chromosome.get_noncenters(chromosome)
    
    node_list = @get_node_list centers, non_centers
    edges_per_center = @get_lines(centers, node_list)

    @get_distance_sum(edges_per_center)

  run: ->
    sol = Chromosome.generate @nodes, @centers
    start_time = Date.now()
    while (Date.now() - start_time)/1000 < @time
      for i in [1..@loops]
        new_s = @perturber sol
        new_fit = @fitness new_s
        old_fit = @fitness sol

        if @foolish
          if new_fit < old_fit
            sol = new_s

        else
          if new_fit < old_fit || Math.random() < (Math.E**((old_fit-new_fit)/@temperature))
            sol = new_s

      @temperature *= @alpha
      @loops *= @beta

    centers = Chromosome.get_centers sol
    noncenters = Chromosome.get_noncenters sol
    node_list = @get_node_list centers, noncenters
    {solution: [sol, @fitness sol], lines: @get_lines centers, node_list}

module.exports = SA
