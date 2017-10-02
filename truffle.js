// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
  networks: {
    testrpc: {
      gas: 8712388,
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ropsten: {
      from: '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
      host: '52.232.79.62',
      port: 8545,
      network_id: '*' // Match any network id
    }
  }
}
