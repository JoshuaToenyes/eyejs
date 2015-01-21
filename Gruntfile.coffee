module.exports = (grunt) ->

  config =

    pkg: (grunt.file.readJSON('package.json'))

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      common:
        expand: true
        flatten: false
        cwd: 'src/coffee'
        src: ['common/**/*.coffee']
        dest: 'tmp'
        ext: '.js'
      chrome:
        expand: true
        flatten: false
        cwd: 'src/coffee'
        src: ['chrome/**/*.coffee']
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
      common:
        files:
          'dist/common/eye.js': ['tmp/common/**/*.js']
      chrome:
        files:
          'dist/chrome/background.js': ['tmp/chrome/background.js']
          'dist/chrome/foreground.js': ['tmp/chrome/foreground.js']
          'dist/chrome/eye.js': ['tmp/common/**/*.js']
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
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['compile']
      configFiles:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    clean:
      dist: ['dist']
      tmp: ['tmp']
      test: ['test/**/*.js']

    replace:
      version:
        src: ["chrome/<%= pkg.version %>"],
        overwrite: true,
        replacements: [{
          from: "*|VERSION|*",
          to: "<%= pkg.version %>"
        }]

    copy:
      chrome:
        files: [
          {
            expand: true
            flatten: true
            src: ['assets/icons/**', 'assets/manifests/chrome/**']
            dest: 'dist/chrome/'
            filter: 'isFile'
          }
        ]

    jade:
      index:
        files:
          'dist/chrome/popup.html': 'src/jade/common/popup.jade'

    sass:
      dist:
        options:
          loadPath: 'lib/'
        files:
          'dist/assets/css/app.css': 'src/sass/app.sass'





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
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-sass')

  grunt.registerTask 'compile', [
    'coffeelint'
    'clean:dist'
    'coffee'
    'browserify'
    'replace:version'
    'clean:tmp'
    'copy'
    'jade'
  ]

  grunt.registerTask 'test', [
    'compile'
    'mocha_phantomjs'
  ]
