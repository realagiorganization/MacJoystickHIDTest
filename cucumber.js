module.exports = {
  default: {
    require: [
      'tests/support/**/*.js',
      'tests/steps/**/*.js'
    ],
    paths: ['tests/features/**/*.feature'],
    format: ['progress']
  }
};
