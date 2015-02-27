module.exports = (grunt) ->

  grunt.task.loadNpmTasks 'grunt-contrib-watch'
  grunt.task.loadNpmTasks 'grunt-coffeelint'
  grunt.task.loadNpmTasks 'grunt-gh-pages'

  grunt.initConfig
    pkg:
      grunt.file.readJSON 'package.json'

    'gh-pages':
      src: ['**']
      options:
        base: 'doks'
        add: yes

    coffeelint:
      dist:
        files:
          src: [ 'src/**/*.coffee' ]

      options:
        max_line_length:
          level: 'ignore'
        no_backticks:
          level: 'ignore'
        #no_empty_param_list:
        #  level: 'warn'
        prefer_english_operator:
          level: 'warn'

    watch:
      dist:
        files: 'src/**/*.coffee'
        tasks: [ 'coffeelint' ]

  grunt.event.on 'coffee.error', (msg) ->
    grunt.log.write msg

  grunt.registerTask 'default', [ 'coffeelint' ]
  grunt.registerTask 'dev', [ 'coffeelint', 'watch' ]