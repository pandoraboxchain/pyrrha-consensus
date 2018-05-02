'use strict';

require('@babel/register');

const HDWalletProvider = require("truffle-hdwallet-provider");

const infura_apikey = process.env.INFURA_API_KEY;
const mnemonic = process.env.HDWALLET_MNEMONIC;
const lowGas = 4700000;
const highGas = 6700000;

module.exports = {
  networks: {
    cli: {
      host: 'localhost',
      port: 8545,
      network_id: '*'
    },
    infura_ropsten: {
      provider: _ => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/" + infura_apikey),
      network_id: 3,
      gas: lowGas
    },
    infura_rinkeby: {
      provider: _ => new HDWalletProvider(mnemonic, "https://rinkeby.infura.io/" + infura_apikey),
      network_id: '*',
      gas: highGas
    },
    pandora_rinkeby: {
      host: 'pandora.network',
      port: 8545,
      network_id: '*'
    }
  }
}
