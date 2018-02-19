// Allows us to use ES6 in our migrations and tests.
require('babel-register')

var HDWalletProvider = require("truffle-hdwallet-provider");

var infura_apikey = "5d45HvcGSajS3BtffliU";
var mnemonic = "dinner govern better mix core bean illegal rain crash afraid double company";

module.exports = {
  networks: {
    testrpc: {
      gas: 4700000,
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ganache: {
      gas: 7900000,
      host: 'localhost',
      port: 7545,
      network_id: '5777'
    },
    infura: {
      provider: _ => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3,
      gas: 4700000
    },
    ropsten: {
      from: '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
      host: '52.232.79.62',
      port: 8545,
      network_id: '3' // Match any network id
    },
    testnet: {
      gas: 4700000,
      from: '0x00Ea169ce7e0992960D3BdE6F5D539C955316432',
      host: '52.232.83.9',
      port: 8545,
      network_id: '*' // Match any network id
    }
  }
}
