(function() {
  var Chromosome, SA, helpers;

  helpers = require('./helpers');

  Chromosome = require('./chromosome');

  SA = (function() {
    function SA(opts) {
      helpers.extend(this, opts);
      this.nodes = this.data.length;
    }

    SA.perturb = function(chromosome) {
      var centers, index, loc, rand, split_chromosome;
      split_chromosome = chromosome.split("").map(function(val) {
        return parseInt(val);
      });
      centers = Chromosome.get_centers(chromosome);
      rand = helpers.get_random_int(0, centers.length - 1);
      loc = helpers.get_random_int(0, split_chromosome.length - 1);
      index = centers[rand];
      split_chromosome.splice(index, 1);
      split_chromosome.splice(loc, 0, 1);
      return split_chromosome.join("");
    };

    SA.pairwise_switch = function(chromosome) {
      var centers, loc1, loc2, split_chromosome, val1, val2;
      split_chromosome = chromosome.split("").map(function(val) {
        return parseInt(val);
      });
      centers = Chromosome.get_centers(chromosome);
      loc1 = helpers.get_random_int(0, split_chromosome.length - 1);
      loc2 = helpers.get_random_int(0, split_chromosome.length - 1);
      val1 = split_chromosome[loc1];
      val2 = split_chromosome[loc2];
      split_chromosome[loc1] = val2;
      split_chromosome[loc2] = val1;
      return split_chromosome.join("");
    };

    SA.prototype.distance = function(src, tgt) {
      var src_x, src_y, tgt_x, tgt_y, _ref, _ref1;
      _ref = this.data[src], src_x = _ref[0], src_y = _ref[1];
      _ref1 = this.data[tgt], tgt_x = _ref1[0], tgt_y = _ref1[1];
      return Math.sqrt(Math.pow(tgt_y - src_y, 2) + Math.pow(tgt_x - src_x, 2));
    };

    SA.prototype.get_distance_sum = function(obj) {
      var array, key, mapped_distances, node;
      array = (function() {
        var _results;
        _results = [];
        for (key in obj) {
          array = obj[key];
          _results.push((function() {
            var _i, _len, _results1;
            _results1 = [];
            for (_i = 0, _len = array.length; _i < _len; _i++) {
              node = array[_i];
              _results1.push(this.distance(key, node));
            }
            return _results1;
          }).call(this));
        }
        return _results;
      }).call(this);
      mapped_distances = array.map(function(sub_array) {
        return sub_array.reduce((function(total, next) {
          return total + next;
        }), 0);
      });
      return mapped_distances.reduce(function(total, next) {
        return total + next;
      });
    };

    SA.prototype.get_lines = function(centers, node_list) {
      var array, candidate, edges_per_center, i, nc_node_list, used, _i, _j, _k, _l, _len, _len1, _len2, _len3;
      used = [];
      edges_per_center = {};
      for (_i = 0, _len = node_list.length; _i < _len; _i++) {
        array = node_list[_i];
        array.sort((function(_this) {
          return function(a, b) {
            return _this.distance(a[0], a[1]) - _this.distance(b[0], b[1]);
          };
        })(this));
      }
      for (_j = 0, _len1 = centers.length; _j < _len1; _j++) {
        i = centers[_j];
        edges_per_center[i] = [];
      }
      for (_k = 0, _len2 = node_list.length; _k < _len2; _k++) {
        nc_node_list = node_list[_k];
        for (_l = 0, _len3 = nc_node_list.length; _l < _len3; _l++) {
          candidate = nc_node_list[_l];
          if (!helpers.contains(used, candidate[0]) && edges_per_center[candidate[1]].length < this.capacity) {
            edges_per_center[candidate[1]].push(candidate[0]);
            used.push(candidate[0]);
          } else {
            continue;
          }
        }
      }
      return edges_per_center;
    };

    SA.prototype.get_node_list = function(centers, non_centers) {
      var c_node, nc_node, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = non_centers.length; _i < _len; _i++) {
        nc_node = non_centers[_i];
        _results.push((function() {
          var _j, _len1, _results1;
          _results1 = [];
          for (_j = 0, _len1 = centers.length; _j < _len1; _j++) {
            c_node = centers[_j];
            _results1.push([nc_node, c_node]);
          }
          return _results1;
        })());
      }
      return _results;
    };

    SA.prototype.fitness = function(chromosome) {
      var centers, edges_per_center, node_list, non_centers;
      centers = Chromosome.get_centers(chromosome);
      non_centers = Chromosome.get_noncenters(chromosome);
      node_list = this.get_node_list(centers, non_centers);
      edges_per_center = this.get_lines(centers, node_list);
      return this.get_distance_sum(edges_per_center);
    };

    SA.prototype.run = function() {
      var centers, i, new_fit, new_s, node_list, noncenters, old_fit, sol, start_time, _i, _ref;
      sol = Chromosome.generate(this.nodes, this.centers);
      start_time = Date.now();
      while ((Date.now() - start_time) / 1000 < this.time) {
        for (i = _i = 1, _ref = this.loops; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          new_s = this.perturber(sol);
          new_fit = this.fitness(new_s);
          old_fit = this.fitness(sol);
          if (this.foolish) {
            if (new_fit < old_fit) {
              sol = new_s;
            }
          } else {
            if (new_fit < old_fit || Math.random() < (Math.pow(Math.E, (old_fit - new_fit) / this.temperature))) {
              sol = new_s;
            }
          }
        }
        this.temperature *= this.alpha;
        this.loops *= this.beta;
      }
      centers = Chromosome.get_centers(sol);
      noncenters = Chromosome.get_noncenters(sol);
      node_list = this.get_node_list(centers, noncenters);
      return {
        solution: [sol, this.fitness(sol)],
        lines: this.get_lines(centers, node_list)
      };
    };

    return SA;

  })();

  module.exports = SA;

}).call(this);
