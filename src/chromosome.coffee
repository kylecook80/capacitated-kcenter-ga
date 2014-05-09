helpers = require './helpers'

class Chromosome
  @generate: (num, centers) ->
    array = Array.apply(null, Array(num)).map(Number.prototype.valueOf, 0)
    for i in [0..centers-1]
      rand = helpers.get_random_int(0, num-1)
      array[rand] = 1
    array.join("")

  @generate_bit_string: (length) ->
    array = for i in [0..length-1]
      helpers.get_random_int(0, 1)

    array.join("")

  @invert_chromosome: (chromosome) ->
    split_chromosome = chromosome.split("").map (val) -> parseInt val
    inverted = for i in [0..split_chromosome.length-1]
      if split_chromosome[i] == 0
        1
      else
        0
    inverted.join("")

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

module.exports = Chromosome
