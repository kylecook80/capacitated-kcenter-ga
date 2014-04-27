GA = require './ga'
SA = require './sa'
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
console.log "Generational Genetic Algorithm: "
console.log results
console.log ""

sa = new SA
  data: data
  temperature: 10
  alpha: 0.95
  beta: 1.03
  centers: 4
  capacity: 7
  loops: 300
  time: 10

result = sa.run()
console.log "Simulated Annealing: "
console.log result
console.log ""
