// Allows us to use ES6 in our migrations and tests.
require('babel-register')

var HDWalletProvider = require("truffle-hdwallet-provider");

var infura_apikey = "5d45HvcGSajS3BtffliU";
var mnemonic = "dinner govern better mix core bean illegal rain crash afraid double company";

module.exports = {
  networks: {
    testrpc: {
      gas: 8712388,
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    infura: {
      provider: new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3
    },
    ropsten: {
      from: '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
      //privateKey: 'f23190d747c23e1db19c9b52998033f66a04c4ad5f799b1b73b74e174bb65ea1',
      host: '52.232.79.62',
      port: 8545,
      network_id: '3' // Match any network id
    }
  }
}
