module.exports = (grunt) ->

  grunt.task.loadNpmTasks 'grunt-contrib-watch'
  grunt.task.loadNpmTasks 'grunt-coffeelint'

  grunt.initConfig
    pkg:
      grunt.file.readJSON 'package.json'

    coffeelint:
      dist:
        files:
          src: [ 'src/**/*.coffee' ]

      options:
        max_line_length:
          level: 'ignore'

    watch:
      dist:
        files: 'src/**/*.coffee'
        tasks: [ 'coffeelint' ]

  grunt.event.on 'coffee.error', (msg) ->
    grunt.log.write msg

  grunt.registerTask 'default', [ 'coffeelint' ]
  grunt.registerTask 'dev', [ 'watch' ]