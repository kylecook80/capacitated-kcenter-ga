(function() {
  var Generate;

  Generate = {};

  Generate.gen_data_around_center = function(center, radius, nodes) {
    var array, point1, point2, range_x, range_y;
    array = [center];
    while (array.length < nodes) {
      range_x = [center[0] - radius, center[0] + radius];
      range_y = [center[1] - radius, center[1] + radius];
      point1 = helpers.get_random_int.apply(null, range_x);
      point2 = helpers.get_random_int.apply(null, range_y);
      array.push([point1, point2]);
    }
    return array;
  };

  module.exports = Generate;

}).call(this);
