#gulp-uglify : 压缩js

__build__ = "build"

gulp = require "gulp"
uglify = require "gulp-uglify"

swallowError = (error) ->
# If you want details of the error in the console
  console.log error.toString()
  @emit "end"

#============================js压缩合并===========================
gulp.task "js", ->
  gulp.src([
    "webug.js"
  ])
  .pipe uglify()
  .pipe gulp.dest "#{__build__}/"

#============================默认===========================
gulp.task "default", ["js"]
