(function() {
  var Chromosome, GA, Population, helpers;

  helpers = require('./helpers');

  Population = (function() {
    function Population(opts) {
      var array, chromosome, outer_counter;
      helpers.extend(this, opts);
      array = [];
      outer_counter = 0;
      while (outer_counter < this.size) {
        chromosome = Chromosome.generate(this.nodes, this.centers);
        if (!Chromosome.check_feasibility(chromosome, this.centers)) {
          continue;
        }
        array.push(chromosome);
        outer_counter += 1;
      }
      this.population = array;
      this;
    }

    Population.prototype.run_roulette = function(roulette) {
      var i, idx, rand, _i, _len;
      rand = Math.random();
      for (idx = _i = 0, _len = roulette.length; _i < _len; idx = ++_i) {
        i = roulette[idx];
        if (rand < i) {
          return idx;
        }
      }
    };

    Population.prototype.get_pop = function() {
      return this.population;
    };

    return Population;

  })();

  Chromosome = (function() {
    function Chromosome() {}

    Chromosome.generate = function(num, centers) {
      var array, i, rand, _i, _ref;
      array = Array.apply(null, Array(num)).map(Number.prototype.valueOf, 0);
      for (i = _i = 0, _ref = centers - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        rand = helpers.get_random_int(0, num - 1);
        array[rand] = 1;
      }
      return array.join("");
    };

    Chromosome.get_centers = function(chromosome) {
      return chromosome.split("").map(function(node, idx) {
        if (parseInt(node) === 1) {
          return idx;
        } else {
          return null;
        }
      }).filter(function(obj) {
        return obj !== null;
      });
    };

    Chromosome.get_noncenters = function(chromosome) {
      return chromosome.split("").map(function(node, idx) {
        if (parseInt(node) === 0) {
          return idx;
        } else {
          return null;
        }
      }).filter(function(obj) {
        return obj !== null;
      });
    };

    Chromosome.check_feasibility = function(chromosome, centers) {
      var total;
      total = chromosome.split("").reduce((function(total, next) {
        return total + parseInt(next);
      }), 0);
      if (total === centers) {
        return true;
      } else {
        return false;
      }
    };

    Chromosome.get_max_distance_with_index = function(array) {
      var best, best_idx, distance, idx, _i, _len;
      best = 0;
      best_idx = 0;
      for (idx = _i = 0, _len = array.length; _i < _len; idx = ++_i) {
        distance = array[idx];
        if (distance > best) {
          best = distance;
          best_idx = idx;
        }
      }
      return [best, best_idx];
    };

    return Chromosome;

  })();

  GA = (function() {
    function GA(opts) {
      helpers.extend(this, opts);
      this.nodes = this.data.length;
      this.population = new Population({
        size: this.population_size,
        nodes: this.nodes,
        centers: this.centers
      });
    }

    GA.prototype.distance = function(src, tgt) {
      var src_x, src_y, tgt_x, tgt_y, _ref, _ref1;
      _ref = this.data[src], src_x = _ref[0], src_y = _ref[1];
      _ref1 = this.data[tgt], tgt_x = _ref1[0], tgt_y = _ref1[1];
      return Math.sqrt(Math.pow(tgt_y - src_y, 2) + Math.pow(tgt_x - src_x, 2));
    };

    GA.prototype.get_distance_sum = function(obj) {
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

    GA.prototype.get_lines = function(centers, node_list) {
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

    GA.prototype.get_node_list = function(centers, non_centers) {
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

    GA.prototype.fitness = function(chromosome) {
      var centers, edges_per_center, node_list, non_centers;
      centers = Chromosome.get_centers(chromosome);
      non_centers = Chromosome.get_noncenters(chromosome);
      node_list = this.get_node_list(centers, non_centers);
      edges_per_center = this.get_lines(centers, node_list);
      return this.get_distance_sum(edges_per_center);
    };

    GA.prototype.fitness_all = function(pop) {
      return pop.map((function(_this) {
        return function(chromosome) {
          return _this.fitness(chromosome);
        };
      })(this));
    };

    GA.prototype.selection = function(population, pop_fitness) {
      var first, i, rand, second, selected, _i;
      if (pop_fitness == null) {
        pop_fitness = null;
      }
      selected = [];
      if (!pop_fitness) {
        pop_fitness = this.fitness_all(population);
      }
      for (i = _i = 0; _i <= 1; i = ++_i) {
        first = helpers.get_random_int(0, pop_fitness.length - 1);
        second = helpers.get_random_int(0, pop_fitness.length - 1);
        while (first === second) {
          second = helpers.get_random_int(0, pop_fitness.length - 1);
        }
        rand = Math.random();
        if (pop_fitness[first] > pop_fitness[second]) {
          if (rand < 0.75) {
            selected.push(first);
          } else {
            selected.push(second);
          }
        } else {
          if (rand < 0.75) {
            selected.push(second);
          } else {
            selected.push(first);
          }
        }
      }
      return selected;
    };

    GA.prototype.cross = function(chromosomes) {
      var first, first_slice1, first_slice2, rand, second, second_slice1, second_slice2;
      first = chromosomes[0], second = chromosomes[1];
      rand = helpers.get_random_int(1, first.length - 1);
      first_slice1 = first.slice(0, rand);
      first_slice2 = first.slice(rand, first.length);
      second_slice1 = second.slice(0, rand);
      second_slice2 = second.slice(rand, second.length);
      first = first_slice1.concat(second_slice2);
      second = second_slice1.concat(first_slice2);
      return [first, second];
    };

    GA.prototype.uniform_cross = function(chromosomes) {};

    GA.prototype.mutate = function(chromosome) {
      var new_chromosome, rand;
      rand = helpers.get_random_int(0, chromosome.length - 1);
      new_chromosome = chromosome.split("").map(function(val) {
        return parseInt(val);
      });
      if (new_chromosome[rand] === 0) {
        new_chromosome[rand] = 1;
      } else {
        new_chromosome[rand] = 0;
      }
      return new_chromosome.join("");
    };

    GA.prototype.repair = function(chromosome) {
      var centers, chromosome_new, diff, i, noncenters, rand, total, _i, _j, _ref, _ref1;
      centers = Chromosome.get_centers(chromosome);
      total = centers.length;
      diff = total - this.centers;
      chromosome_new = chromosome.split("");
      if (diff > 0) {
        for (i = _i = 0, _ref = diff - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          rand = helpers.get_random_int(0, centers.length - 1);
          chromosome_new[centers[rand]] = '0';
        }
      } else {
        for (i = _j = 0, _ref1 = Math.abs(diff) - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 0 <= _ref1 ? ++_j : --_j) {
          noncenters = Chromosome.get_noncenters(chromosome);
          rand = helpers.get_random_int(0, noncenters.length - 1);
          chromosome_new[noncenters[rand]] = '1';
        }
      }
      return chromosome_new.join("");
    };

    GA.prototype.generational_run = function() {
      var best, best_centers, best_non_centers, child_pool, chromosome, crossed, gen, i, idx, lines, node_list, non_biased_chromosomes, parent_pool, pop_fitness, population, random_int, _i, _j, _len, _ref;
      population = this.population.get_pop();
      best = [population[0], population[1]];
      for (gen = _i = 0, _ref = this.generations; 0 <= _ref ? _i <= _ref : _i >= _ref; gen = 0 <= _ref ? ++_i : --_i) {
        parent_pool = [];
        child_pool = [];
        pop_fitness = this.fitness_all(population);
        while (parent_pool.length < this.population_size) {
          parent_pool.push(this.selection(population, pop_fitness));
        }
        while (child_pool.length < this.population_size) {
          non_biased_chromosomes = (function() {
            var _j, _results;
            _results = [];
            for (i = _j = 0; _j <= 1; i = ++_j) {
              random_int = helpers.get_random_int(0, parent_pool.length - 1);
              _results.push(population[random_int]);
            }
            return _results;
          })();
          if (Math.random() < this.crossover) {
            crossed = this.cross(non_biased_chromosomes);
            crossed.forEach(function(val) {
              return child_pool.push(val);
            });
          }
          if (Math.random() < this.mutation) {
            random_int = helpers.get_random_int(0, 1);
            child_pool[non_biased_chromosomes[random_int]] = this.mutate(non_biased_chromosomes[random_int]);
          }
        }
        child_pool.forEach((function(_this) {
          return function(chromosome, idx) {
            if (!Chromosome.check_feasibility(chromosome, _this.centers)) {
              return child_pool[idx] = _this.repair(chromosome);
            }
          };
        })(this));
        for (idx = _j = 0, _len = child_pool.length; _j < _len; idx = ++_j) {
          chromosome = child_pool[idx];
          if (this.fitness(chromosome) < this.fitness(best[0])) {
            if (Chromosome.check_feasibility(chromosome, this.centers)) {
              best[0] = chromosome;
            }
          } else if (this.fitness(chromosome) < this.fitness(best[1])) {
            if (Chromosome.check_feasibility(chromosome, this.centers)) {
              best[1] = chromosome;
            }
          }
        }
        population = child_pool;
        population.splice(0, 2, best[0], best[1]);
      }
      best_centers = Chromosome.get_centers(best[0]);
      best_non_centers = Chromosome.get_noncenters(best[0]);
      node_list = this.get_node_list(best_centers, best_non_centers);
      lines = this.get_lines(best_centers, node_list);
      return {
        best: [best[0], this.fitness(best[0])],
        lines: lines
      };
    };

    GA.prototype.steady_state_run = function() {
      var all_fitness, best, gen, i, index, max, new_min, population, rand, selected, _i, _j, _ref;
      population = this.population.get_pop();
      best = this.fitness(population[0]);
      for (gen = _i = 0, _ref = this.generations; 0 <= _ref ? _i <= _ref : _i >= _ref; gen = 0 <= _ref ? ++_i : --_i) {
        all_fitness = this.fitness_all(population);
        selected = this.selection(population).map(function(val) {
          return population[val];
        });
        if (Math.random() < this.crossover) {
          selected = this.cross(selected);
        }
        if (Math.random() < this.mutation) {
          rand = helpers.get_random_int(0, 1);
          selected[rand] = this.mutate(selected[rand]);
        }
        selected.forEach((function(_this) {
          return function(chromosome, idx) {
            if (!Chromosome.check_feasibility(chromosome, _this.centers)) {
              return selected[idx] = _this.repair(chromosome);
            }
          };
        })(this));
        for (i = _j = 0; _j <= 1; i = ++_j) {
          max = helpers.max(all_fitness);
          index = all_fitness.indexOf(max);
          population[index] = selected[i];
        }
        new_min = helpers.min(all_fitness);
        if (new_min < best) {
          best = new_min;
        }
      }
      console.log("chromosome: " + population[all_fitness.indexOf(best)]);
      return console.log("fitness: " + best);
    };

    return GA;

  })();

  module.exports = GA;

}).call(this);
