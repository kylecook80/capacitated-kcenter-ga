module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    watch:
      scripts:
        files: [
          '**/*.coffee'
          '**/*.jade'
        ]
        tasks: ['coffee:compile', 'jade:compile']
        options:
          spawn: false
    coffee:
      compile:
        files:
          './compiled/ga.js': './src/ga.coffee'
          './compiled/sa.js': './src/sa.coffee'
          './compiled/graph.js': './src/graph.coffee'
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
          pretty: false
          data:
            debug: false
        files:
          './compiled/index.html': './src/display.jade'

  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'

  grunt.registerTask 'default', ['coffee:compile', 'jade:compile']
