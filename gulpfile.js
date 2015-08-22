var gulp = require('gulp'),
    rename = require('gulp-rename'),
    coffee = require('gulp-coffee'),
    uglify = require('gulp-uglify');

// Scripts
gulp.task('scripts', function() {
  return gulp.src('src/*.coffee')
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest('dist/'))
    .pipe(uglify())
    .pipe(rename({suffix: ".min"}))
    .pipe(gulp.dest('dist/'));
});

// Default task
gulp.task('default', function() {
  gulp.watch('src/*.coffee', ['scripts']);
});


