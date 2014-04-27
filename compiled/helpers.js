(function() {
  var Helpers;

  Helpers = {};

  Helpers.get_random_int = function(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  };

  Helpers.clamp = function(value, min, max) {
    return Math.min(Math.max(this, min), max);
  };

  Helpers.extend = function(parent, child) {
    var prop, _results;
    _results = [];
    for (prop in child) {
      _results.push(parent[prop] = child[prop]);
    }
    return _results;
  };

  Helpers.contains = function(array, val) {
    if (array.indexOf(val) >= 0) {
      return true;
    }
    return false;
  };

  Helpers.flatten = function(array) {
    return array.concat.apply([], array);
  };

  Helpers.max = function(array) {
    return Math.max.apply(null, array);
  };

  Helpers.min = function(array) {
    return Math.min.apply(null, array);
  };

  module.exports = Helpers;

}).call(this);
