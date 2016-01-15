gulp = require 'gulp'
coffee = require 'gulp-coffee'

gulp.task 'build', ->

  gulp.src 'src/*.coffee'
  .pipe coffee bare: true
  .pipe gulp.dest './dist'

gulp.task 'watch', ['build'], ->

  gulp.watch 'src/**/*.coffee', ['build']

gulp.task 'default', ['build']
