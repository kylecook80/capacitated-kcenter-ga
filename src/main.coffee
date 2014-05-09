#!/usr/bin/env coffee

fs = require 'fs'
commander = require 'commander'
Handlebars = require 'handlebars'

GA = require './ga'
SA = require './sa'
helpers = require './helpers'

html = """
<!DOCTYPE html>
<html>
  <head>
    <title>Evolutionary Computation Project</title>
    <link rel="stylesheet" href="bower_components/bootstrap/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="bower_components/bootstrap/dist/css/bootstrap-theme.min.css">
    <link rel="stylesheet" href="bower_components/font-awesome/css/font-awesome.min.css">
  </head>
  <body>
    <div id="visualize" class="row">
      <div id="container" class="col-md-12"></div>
    </div>
    <script src="bower_components/jquery/dist/jquery.min.js"></script>
    <script src="bower_components/bootstrap/dist/js/bootstrap.min.js"></script>
    <script src="bower_components/d3/d3.min.js" charset="utf-8"></script>
    <script src="compiled/graph.js"></script>
    <script>
      $(document).ready(function() {
        var nodes = {{nodes}};
        var modulus = {{modulus}};
        var lines = {{{lines}}};
        window.generate_graph(nodes, modulus, lines);
      });
    </script>
  </body>
</html>
"""

template = Handlebars.compile(html)

myParseInt = (string, defaultValue) ->
  int = parseInt string, 10
  if typeof int == 'number'
    return int
  else
    return defaultValue

check_opts = (options) ->
  if !options.parent.data
    console.log "No data file provided. Exiting..."
    process.exit(1)

  if !options.parent.output
    console.log "No output file provided. Exiting..."
    process.exit(1)

get_cx_op = (val) =>
  if val == 'single-point' then return GA.cross
  if val == 'uniform' then return GA.uniform_cross

get_mx_op = (val) =>
  if val == 'random' then return GA.mutate
  if val == 'bit-switch' then return GA.bit_switch

get_perturb_func = (val) =>
  if val == 'single-move' then return SA.perturb
  if val == 'pairwise-switch' then return SA.pairwise_switch

gen_data_around_center = (center, radius, nodes) ->
  array = [center]
  while array.length < nodes
    range_x = [center[0]-radius, center[0]+radius]
    range_y = [center[1]-radius, center[1]+radius]

    point1 = helpers.get_random_int.apply null, range_x
    point2 = helpers.get_random_int.apply null, range_y

    array.push [point1, point2]
  array

commander
  .version('0.0.1')
  .option('-d, --data <file>', 'Data input')
  .option('-o, --output <file>', 'File output')

commander
  .command('ga')
  .description('Run Genetic Algorithm')
  .option('-g, --generations [int]', 'Number of Generations', myParseInt, 500)
  .option('-p, --population [size]', 'Population Size', myParseInt, 100)
  .option('-c, --crosser [type]', 'Crossover operator ["single-point", "uniform"]', get_cx_op, get_cx_op('single-point'))
  .option('-r, --crossover-rate [float]', 'Crossover Rate', parseFloat, 0.95)
  .option('-m, --mutator [type]', 'Mutation operator ["random"]', get_mx_op, get_mx_op('random'))
  .option('-t, --mutation-rate [float]', 'Mutation Rate', parseFloat, 0.05)
  .option('-n, --centers [int]', 'Number of Centers', myParseInt, 4)
  .option('-y, --capacity [int]', 'Capacity of Center Nodes', myParseInt, 7)
  .action((options) ->
    # check_opts(options)

    data = fs.readFileSync(options.parent.data).toString()
    parsed_data = JSON.parse(data)
    nodes = parsed_data.nodes
    centers = parsed_data.centers

    output = options.parent.output

    k_center = new GA
      data: nodes
      population_size: options.population
      generations: options.generations
      crossover: options.crossoverRate
      mutation: options.mutationRate
      centers: options.centers
      capacity: options.capacity
      crosser: options.crosser
      mutator: options.mutator

    results = k_center.generational_run()
    console.log results
    rendered = template
      nodes: JSON.stringify(nodes)
      modulus: nodes.length / centers.length
      lines: JSON.stringify(results.lines)

    fs.writeFile output, rendered, (err) ->
      if err then throw err
      console.log('Successfully saved results to: ' + output)
  )

commander
  .command('sa')
  .description('Run Simulated Annealing Algorithm')
  .option('-t, --time [seconds]', 'Time to Run Algorithm in seconds', myParseInt, 10)
  .option('-e, --temperature [int]', 'Starting Temperature', myParseInt, 10)
  .option('-p, --perturber [type]', 'Perturbation Function', get_perturb_func, get_perturb_func('single-move'))
  .option('-a, --alpha [float]', 'Percentage to decrease Temperature by', parseFloat, 0.95)
  .option('-b, --beta [float]', 'Percentage to increase iterations by', parseFloat, 1.03)
  .option('-i, --iterations [int]', 'Number of iterations before decreasing temperature', myParseInt, 300)
  .option('-n, --centers [int]', 'Number of Centers', myParseInt, 4)
  .option('-y, --capacity [int]', 'Capacity of Center Nodes', myParseInt, 7)
  .option('-f, --foolish', 'Foolish Hillclimbing')
  .action((options) ->
    # check_opts(options)

    data = fs.readFileSync(options.parent.data)
    parsed_data = JSON.parse(data)
    nodes = parsed_data.nodes
    centers = parsed_data.centers
    foolish = if options.foolish then true else false
    output = options.parent.output

    k_center = new SA
      data: nodes
      temperature: options.temperature
      perturber: options.perturber
      alpha: options.alpha
      beta: options.beta
      centers: options.centers
      capacity: options.capacity
      loops: options.iterations
      time: options.time
      foolish: foolish

    results = k_center.run()
    console.log results
    rendered = template
      nodes: JSON.stringify(nodes)
      modulus: nodes.length / centers.length
      lines: JSON.stringify(results.lines)

    fs.writeFile output, rendered, (err) ->
      if err then throw err
      console.log('Successfully saved results to: ' + output)
  )

commander
  .command('gen')
  .description('Generate Test Data')
  .option('-c, --centers [[x,y],...]', 'Array of centers')
  .option('-r, --radius [int]', 'Radius around center to generate', myParseInt)
  .option('-n, --nodes [int]', 'Number of nodes to generate per center', myParseInt)
  .action((options) ->
    centers = JSON.parse options.centers
    radius = options.radius
    num_nodes = options.nodes
    output = options.parent.output

    nodes = for i in [0..centers.length-1]
      gen_data_around_center(centers[i], radius, num_nodes)

    nodes = helpers.flatten nodes

    json = {
      centers: centers
      nodes: nodes
    }

    stringify_json = JSON.stringify json

    fs.writeFile output, stringify_json, (err) ->
      if err then throw err
      console.log('Successfully saved generated nodes to: ' + output)
  )

commander.parse(process.argv)
