// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      /* from: '0xbcd19a6a5450c6ab13807f4f2a958f192c502a18', */
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    }
  }
}
