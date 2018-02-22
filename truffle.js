// Allows us to use ES6 in our migrations and tests.
require('babel-register')

const HDWalletProvider = require("truffle-hdwallet-provider")

const infura_apikey = "5d45HvcGSajS3BtffliU"
const mnemonic = "dinner govern better mix core bean illegal rain crash afraid double company"

const lowGas = 4700000
const highGas = 6700000

module.exports = {
  networks: {
    cli: {
      host: 'localhost',
      port: 8545,
      gas: lowGas,
      network_id: '*' // Match any network id
    },
    ganache: {
      host: 'localhost',
      port: 7545,
      gas: highGas,
      network_id: '5777'
    },

    infura_ropsten: {
      provider: _ => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/"+infura_apikey),
      network_id: 3,
      gas: lowGas
    },
    infura_rinkeby: {
      provider: _ => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/"+infura_apikey),
      network_id: '*',
      gas: lowGas
    },

    ropsten: {
      host: '52.232.79.62',
      port: 8545,
      from: '0x17e83c2899a917ad4b8a1ac8f1574ca8a8e71d02',
      network_id: '3' // Match any network id
    },
    private_parity: {
      host: '52.232.83.9',
      port: 8545,
      from: '0x00Ea169ce7e0992960D3BdE6F5D539C955316432',
      gas: lowGas,
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
