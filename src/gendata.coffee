Generate = {}

Generate.gen_data_around_center = (center, radius, nodes) ->
  array = [center]
  while array.length < nodes
    range_x = [center[0]-radius, center[0]+radius]
    range_y = [center[1]-radius, center[1]+radius]

    point1 = helpers.get_random_int.apply null, range_x
    point2 = helpers.get_random_int.apply null, range_y

    array.push [point1, point2]
  array

module.exports = Generate
