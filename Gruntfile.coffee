module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    watch:
      scripts:
        files: [
          './src/visualization/*.coffee'
          './src/visualization/*.jade'
        ]
        tasks: ['coffee:compile', 'jade:compile']
        options:
          spawn: false
    coffee:
      compile:
        files:
          './compiled/visualize.js': './src/visualization/visualize.coffee'
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
          'compiled/display.html': './src/visualization/display.jade'


  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-newer'

  grunt.registerTask 'default', ['coffee:compile', 'jade:compile']
