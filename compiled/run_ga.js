(function() {
  var GA, k_center, opts;

  GA = require('./ga');

  opts = process.argv[0];

  k_center = new GA(opts);

  k_center.run();

}).call(this);
