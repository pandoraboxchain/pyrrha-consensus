'use strict';

require('@babel/register');
require('@babel/polyfill');

const PrivateKeyProvider = require('truffle-privatekey-provider');

const infura_apikey = process.env.INFURA_API_KEY;
let privateKey = process.env.ACCOUNT_PRIVATE_KEY;

try {
    privateKey = require('./localkeys').key;
} catch(err) {
    console.log('LocalKeys Error:', err);
}

const lowGas = 4712388;
const highGas = 6700000;

module.exports = {
    networks: {
        ganache: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 76000000
        },
        coverage: {
            host: 'localhost',
            port: 8555,
            network_id: '*',
            gas: 0xfffffffffff,
            gasPrice: 0x01
        },
        infura_ropsten: {
            provider: _ => new PrivateKeyProvider(privateKey, `https://ropsten.infura.io/${infura_apikey}`),
            network_id: 3,
            gas: lowGas
        },
        infura_rinkeby: {
            provider: _ => new PrivateKeyProvider(privateKey, `https://rinkeby.infura.io/${infura_apikey}`),
            network_id: '*',
            gas: highGas
        },
        pandora_rinkeby: {
            host:  'http://rinkeby.pandora.network',
            port: 8545,
            network_id: '*',
            gas: highGas
        },
        rsk_test_local: {
            provider: _ => new PrivateKeyProvider(privateKey, `http://localhost:4444`),
            network_id: '*',
            gasPrice: 0
        },
        rsk_test: {
            provider: _ => new PrivateKeyProvider(process.env.RSK_TESTNET_KEY, `http://node.rsk.pandora.network:4444`),
            network_id: '*',
            gasPrice: 0
        }
    },
    mocha: {
        enableTimeouts: false
    }
};
