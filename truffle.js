// Allows us to use ES6 in our migrations and tests.
require('babel-register')

let HDWalletProvider = require("truffle-hdwallet-provider")

let infura_apikey = "5d45HvcGSajS3BtffliU"
let mnemonic = "dinner govern better mix core bean illegal rain crash afraid double company"

module.exports = {
  networks: {
    cli: {
      gas: 4700000,
      host: 'localhost',
      port: 8545,
      network_id: '*' // Match any network id
    },
    ganache: {
      gas: 6700000,
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
      from: '0x17e83c2899a917ad4b8a1ac8f1574ca8a8e71d02',
      host: '52.232.79.62',
      port: 8545,
      network_id: '3' // Match any network id
    },
    rinkeby: {
      provider: _ => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/"+infura_apikey),
      network_id: '*',
      gas: 4700000
    },
    testnet: {
      gas: 4700000,
      from: '0x00Ea169ce7e0992960D3BdE6F5D539C955316432',
      host: '52.232.83.9',
      port: 8545,
      network_id: '*' // Match any network id
    },
    rsktest: {
      host: 'bitcoin.pandora.network',
      port: '4444',
      network_id: '*',
      gasPrice: 0
    }
  }
}
