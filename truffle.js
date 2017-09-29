// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    development: {
      gas: 8712388,
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ropsten: {
      host: '91.225.166.101',
      port: 30303,
      network_id: '*' // Match any network id
    }
  }
}
