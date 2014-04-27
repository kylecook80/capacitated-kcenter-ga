module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    watch:
      scripts:
        files: [
          '**/*.coffee'
          '**/*.jade'
          '**/*.styl'
        ]
        tasks: ['coffee:compile', 'jade:compile', 'stylus:compile']
        options:
          spawn: false
    coffee:
      compile:
        files:
          './compiled/display.js': 'assets/js/display.coffee'
          './compiled/visualize.js': 'assets/js/visualize.coffee'
          './compiled/ga.js': './src/ga.coffee'
          './compiled/gendata.js': './src/gendata.coffee'
          './compiled/helpers.js': './src/helpers.coffee'
      all:
        expand: true,
        flatten: true,
        cwd: './',
        src: ['src/**/*.coffee'],
        dest: './compiled',
        ext: '.js'
    jade:
      compile:
        options:
          pretty: true
          data:
            debug: false
        files:
          './compiled/index.html': './views/display.jade'
    stylus:
      compile:
        files:
          './compiled/index.css': './assets/css/index.styl'


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'

  grunt.registerTask 'default', ['coffee:compile', 'jade:compile', 'stylus:compile']
