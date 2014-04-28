helpers = require './helpers'

# Arguments when instantiating:
# - size: The size of the population.
# - nodes: The number of nodes in the data set
# - centers: The number of nodes required to be centers
class Population
  constructor: (opts) ->
    helpers.extend @, opts

    array = []
    outer_counter = 0

    while outer_counter < @size
      chromosome = Chromosome.generate(@nodes, @centers)

      if !Chromosome.check_feasibility chromosome, @centers
        continue

      array.push chromosome
      outer_counter += 1

    @population = array
    @

  run_roulette: (roulette) ->
    rand = Math.random()
    for i, idx in roulette
      if rand < i
        return idx

  get_pop: ->
    @population

class Chromosome
  @generate: (num, centers) ->
    array = Array.apply(null, Array(num)).map(Number.prototype.valueOf, 0)
    for i in [0..centers-1]
      rand = helpers.get_random_int(0, num-1)
      array[rand] = 1
    array.join("")

  # Given a chromosome, return which indices are center locations.
  @get_centers: (chromosome) ->
    chromosome.split("").map(
      (node, idx) ->
        if parseInt(node) == 1 then idx else null
      ).filter(
      (obj) ->
        obj != null
      )

  # Given a chromosome, return which indices are non-center locations.
  @get_noncenters: (chromosome) ->
    chromosome.split("").map(
      (node, idx) ->
        if parseInt(node) == 0 then idx else null
      ).filter(
      (obj) ->
        obj != null
      )

  @check_feasibility: (chromosome, centers) ->
    total = chromosome.split("").reduce(
      ((total, next) -> total + parseInt(next)), 0
    )
    if total == centers
      true
    else
      false

  @get_max_distance_with_index: (array) ->
    best = 0
    best_idx = 0
    for distance, idx in array
      if distance > best
        best = distance
        best_idx = idx
    [best, best_idx]

# Arguments required for instantiating:
# - data: A two dimensional array of (x,y) coordinates, i.e. [[1,1],[2,2],[3,3]...]
# - population_size: The size of the population we want to use.
# - generations: How many generations we should run for.
# - mutation: The chance of mutation. Given as a number between 0 and 1, i.e. 0.05
# - crossover: The chance of crossover. Given as a number between 0 and 1, i.e. 0.95
# - centers: The number of centers to attempt to find
# - capacity: The capacity of a center
class GA
  constructor: (opts) ->
    helpers.extend @, opts
    @nodes = @data.length
    @population = new Population
      size: @population_size
      nodes: @nodes
      centers: @centers

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

  fitness_all: (pop) ->
    pop.map (chromosome) => @fitness(chromosome)

  selection: (population, pop_fitness=null) ->
    selected = []
    
    unless pop_fitness
      pop_fitness = @fitness_all population

    for i in [0..1]
      first = helpers.get_random_int 0, pop_fitness.length-1
      second = helpers.get_random_int 0, pop_fitness.length-1
      
      while first == second
        second = helpers.get_random_int 0, pop_fitness.length-1

      rand = Math.random()
      if pop_fitness[first] > pop_fitness[second]
        if rand < 0.75
          selected.push first
        else
          selected.push second
      else
        if rand < 0.75
          selected.push second
        else
          selected.push first
    selected

  # Single point
  cross: (chromosomes) ->
    [first, second] = chromosomes
    rand = helpers.get_random_int(1, first.length-1)

    first_slice1 = first.slice(0, rand)
    first_slice2 = first.slice(rand, first.length)
    second_slice1 = second.slice(0, rand)
    second_slice2 = second.slice(rand, second.length)
    
    first = first_slice1.concat second_slice2
    second = second_slice1.concat first_slice2
    
    [first, second]

  uniform_cross: (chromosomes) ->

  # Flip bit
  mutate: (chromosome) ->
    rand = helpers.get_random_int(0, chromosome.length-1)
    new_chromosome = chromosome.split("").map (val) -> parseInt(val)

    if new_chromosome[rand] == 0
      new_chromosome[rand] = 1
    else
      new_chromosome[rand] = 0

    new_chromosome.join("")

  # TODO: sometimes a '1' is randomly selected and the chromosome is not repaired.
  repair: (chromosome) ->
    centers = Chromosome.get_centers(chromosome)
    total = centers.length
    diff = total - @centers
    chromosome_new = chromosome.split("")

    if diff > 0
      for i in [0..diff-1]
        rand = helpers.get_random_int(0, centers.length-1)
        chromosome_new[centers[rand]] = '0'
    else
      for i in [0..Math.abs(diff)-1]
        noncenters = Chromosome.get_noncenters chromosome
        rand = helpers.get_random_int(0, noncenters.length-1)
        chromosome_new[noncenters[rand]] = '1'

    chromosome_new.join("")

  generational_run: ->
    population = @population.get_pop()
    best = [population[0], population[1]]

    for gen in [0..@generations]
      parent_pool = []
      child_pool = []

      pop_fitness = @fitness_all population
      while parent_pool.length < @population_size
        parent_pool.push @selection population, pop_fitness

      while child_pool.length < @population_size
        non_biased_chromosomes = for i in [0..1]
          random_int = helpers.get_random_int(0, parent_pool.length-1)
          population[random_int]

        if Math.random() < @crossover
          crossed = @cross non_biased_chromosomes
          crossed.forEach (val) -> child_pool.push(val)

        if Math.random() < @mutation
          random_int = helpers.get_random_int(0, 1)
          child_pool[non_biased_chromosomes[random_int]] =
            @mutate non_biased_chromosomes[random_int]

      child_pool.forEach (chromosome, idx) =>
        if !Chromosome.check_feasibility chromosome, @centers
          child_pool[idx] = @repair chromosome

      for chromosome, idx in child_pool
        if @fitness(chromosome) < @fitness(best[0])
          best[0] = chromosome if Chromosome.check_feasibility chromosome, @centers
        else if @fitness(chromosome) < @fitness(best[1])
          best[1] = chromosome if Chromosome.check_feasibility chromosome, @centers

      population = child_pool
      population.splice 0, 2, best[0], best[1]

    best_centers = Chromosome.get_centers best[0]
    best_non_centers = Chromosome.get_noncenters best[0]
    node_list = @get_node_list best_centers, best_non_centers
    lines = @get_lines best_centers, node_list

    {best: [best[0], @fitness(best[0])], lines: lines}

  steady_state_run: ->
    population = @population.get_pop()
    best = @fitness population[0]

    for gen in [0..@generations]
      # Fitness of initial population
      # First selected
      all_fitness = @fitness_all population
      selected = @selection(population).map (val) -> population[val]

      # Crossover
      if Math.random() < @crossover
        selected = @cross selected
    
      # Mutation
      if Math.random() < @mutation
        rand = helpers.get_random_int(0, 1)
        selected[rand] = @mutate selected[rand]

      selected.forEach (chromosome, idx) =>
        if !Chromosome.check_feasibility chromosome, @centers
          selected[idx] = @repair chromosome
    
      for i in [0..1]
        max = helpers.max all_fitness
        index = all_fitness.indexOf max
        population[index] = selected[i]

      new_min = helpers.min all_fitness
      
      if new_min < best
        best = new_min

    console.log "chromosome: " + population[all_fitness.indexOf(best)]
    console.log "fitness: " + best

module.exports = GA
