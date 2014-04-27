Helpers = {}

Helpers.get_random_int = (min, max) ->
  Math.floor(Math.random() * (max - min + 1)) + min

Helpers.clamp = (value, min, max) ->
  Math.min(Math.max(this, min), max)

Helpers.extend = (parent, child) ->
  for prop of child
    parent[prop] = child[prop]

Helpers.contains = (array, val) ->
  return true if array.indexOf(val) >= 0
  return false

Helpers.flatten = (array) ->
  array.concat.apply [], array

Helpers.max = (array) ->
  Math.max.apply(null, array)

Helpers.min = (array) ->
  Math.min.apply(null, array)

module.exports = Helpers
