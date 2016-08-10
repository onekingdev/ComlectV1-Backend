var gulp = require('gulp'); 
    jshint = require('gulp-jshint'),
    stylish = require('jshint-stylish'),
    watch = require('gulp-watch'),
    cssnano = require('gulp-cssnano'),
    rtlcss = require('gulp-rtlcss'),
    del = require('del'),
    uglify = require('gulp-uglify'),
    rename = require('gulp-rename');

require('gulp-stats')(gulp);
    
gulp.task('clean', function() {
    return del(['dist']);
});

gulp.task('watch', function() {
  watch("src/js/**/*.js")
    .pipe(jshint())
    .pipe(jshint.reporter(stylish));
});

gulp.task('js', ['clean'], function() {
  return gulp.src('./src/js/**/*.js')
    .pipe(jshint())
    .pipe(uglify())
    .pipe(gulp.dest('dist/js'));
});

gulp.task('css', ['clean'], function() {
   return gulp.src('src/css/**/*.css')
    .pipe(cssnano())
    .pipe(gulp.dest('dist/css'))
	// Till this point, we've only managed to minimize the css.
	
	// Now, take the minimized css and also generate an rtl version of it.
    .pipe(rtlcss())
    .pipe(rename({ suffix: '-rtl' }))
    .pipe(gulp.dest('dist/css'));
});

// 'js' and 'css' will run concurrently, but only after 'clean' is done.
gulp.task('default', ['js', 'css']);