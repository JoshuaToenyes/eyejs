module.exports = (grunt) ->

  config =

    pkg: (grunt.file.readJSON('package.json'))

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      eyejs:
        expand: true
        flatten: false
        cwd: 'src'
        src: ['*.coffee']
        dest: 'tmp'
        ext: '.js'
      test:
        expand: true,
        flatten: false,
        cwd: 'test',
        src: ['./**/*.coffee'],
        dest: 'tmp/test',
        ext: '.js'

    browserify:
      eyejs:
        files:
          'dist/common/eye.js': ['tmp/common/**/*.js']
      test:
        files:
          'test/test.js': ['tmp/test/**/*.js']
        options:
          browserifyOptions:
            debug: true
          preBundleCB: (b) ->
            b.plugin((require 'browserify-testability').plugin)

    # ### mocha_phantomjs
    # Runs mocha tests in PhantomJS.
    mocha_phantomjs:
      all: ['test/**/*.html']

    watch:
      files: [
        'src/**/*.coffee',
        'test/**/*.coffee'],
      tasks: ['compile']
      configFiles:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    clean:
      dist: ['dist']
      tmp: ['tmp']
      test: ['test/**/*.js']
      caches: ['.sass-cache']

    replace:
      version:
        src: ["chrome/<%= pkg.version %>"],
        overwrite: true,
        replacements: [{
          from: "*|VERSION|*",
          to: "<%= pkg.version %>"
        }]


  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-text-replace')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-mocha-phantomjs')

  grunt.registerTask 'compile', [
    'coffeelint'
    'clean:dist'
    'coffee'
    'browserify'
    'replace:version'
    'clean:tmp'
  ]

  grunt.registerTask 'test', [
    'compile'
    'mocha_phantomjs'
  ]

  grunt.registerTask 'release', [
    'test'
  ]
