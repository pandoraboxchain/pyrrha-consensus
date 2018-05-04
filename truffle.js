'use strict';

require('@babel/register');

const PrivateKeyProvider = require("truffle-privatekey-provider");

const infura_apikey = process.env.INFURA_API_KEY;
const privateKey = process.env.ACCOUNT_PRIVATE_KEY;

const lowGas = 4700000;
const highGas = 6700000;

module.exports = {
  networks: {
    cli: {
      host: 'localhost',
      port: 8545,
      network_id: '*'
    },
    coverage: {
      host: 'localhost',
      network_id: '*',
      port: 8555,
      gas: 0xfffffffffff,
      gasPrice: 0x01
    },
    infura_ropsten: {
      provider: _ => new PrivateKeyProvider(privateKey, "https://ropsten.infura.io/" + infura_apikey),
      network_id: 3,
      gas: lowGas
    },
    infura_rinkeby: {
      provider: _ => new PrivateKeyProvider(privateKey, "https://rinkeby.infura.io/" + infura_apikey),
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
