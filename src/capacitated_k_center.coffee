GA = require './ga'
fs = require 'fs'

data = fs.readFileSync('data/trivial.json').toString()
data = JSON.parse(data).nodes

k_center = new GA
  data: data
  population_size: 100
  generations: 500
  mutation: 0.05
  crossover: 0.95
  centers: 4
  capacity: 7

results = k_center.generational_run()
console.log results
