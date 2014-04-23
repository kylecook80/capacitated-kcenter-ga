fs = require 'fs'
express = require 'express'
bodyParser = require 'body-parser'

helpers = require './helpers'
{generator} = require './gendata'
{GA} = require './ga'

app = express()

pub_path = __dirname + '/../bower_components'
data_path = __dirname + '/../data'

app.set 'views', __dirname + '/../views'
app.set 'view engine', 'jade'

app.use express.static(pub_path)
app.use require('connect-assets')()
app.use bodyParser()

app.get '/', (req, res) ->
  fs.readdir data_path, (err, files) ->
    if err
      res.send(err)
    else
      res.render 'display', files: files

app.post '/file/:file', (req, res) ->
  file = data_path + "/" + req.params.file + ".json"
  fs.readFile file, {encoding: 'utf8'}, (err, data) ->
    parsedJson = JSON.parse(data)
    centers = parsedJson.centers.length
    nodes = parsedJson.nodes.length
    if err
      res.send error: err
    else
      res.send status: "success", data: parsedJson.nodes, centers: centers, num_nodes: nodes

app.post '/gen/:file', (req, res) ->
  file = data_path + "/" + req.params.file + ".json"

  centers = req.body.centers
  centers = for array in centers
    array.map (item) -> parseInt(item)

  radius = parseInt req.body.radius
  num_nodes = parseInt req.body.nodes

  all_points = centers.map (center) ->
    generator center, radius, num_nodes
  flat_all_points = helpers.flatten all_points

  store_data = {centers: centers, nodes: flat_all_points}

  parsed_node_data = JSON.stringify store_data, null

  fs.writeFile file, parsed_node_data, (err) ->
    if err
      res.send error: err
    else
      res.send status: "success", data: flat_all_points, centers: centers.length, num_nodes: flat_all_points.length

app.post '/evolve/:file', (req, res) ->
  file = req.params.file
  json = req.body
  
  data = fs.readFileSync('data/'+file).toString()
  parsed_json = JSON.parse(data)
  data = parsed_json.nodes
  centers = parsed_json.centers

  population_size = parseInt json.population_size
  generations = parseInt json.generations
  mutation_rate = parseFloat json.mutation_rate
  crossover_rate = parseFloat json.crossover_rate
  capacity = parseInt json.capacity

  # console.log population_size
  # console.log generations
  # console.log mutation_rate
  # console.log crossover_rate
  # console.log capacity
  # console.log centers

  k_center = new GA
    data: data
    population_size: population_size
    generations: generations
    mutation: mutation_rate
    crossover: crossover_rate
    centers: centers
    capacity: capacity

  results = k_center.generational_run()
  res.send results
  # res.send("OK")

app.listen 3000
console.log "Express running on port 3000."
