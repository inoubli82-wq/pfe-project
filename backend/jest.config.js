module.exports = {
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.js', '**/?(*.)+(spec|test).js'],
  coverageDirectory: 'coverage',
  collectCoverageFrom: [
    'controllers/**/*.js',
    'routes/**/*.js',
    'config/**/*.js',
    'utils/**/*.js',
    '!server.js'
  ],
  testTimeout: 10000,
verbose: true,
  forceExit: true,
  detectOpenHandles: true
};