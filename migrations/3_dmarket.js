'use strict';

const Kernel = artifacts.require('Kernel');
const Dataset = artifacts.require('Dataset');
const Market = artifacts.require('PandoraMarket');
const {
    saveAddressToFile
} = require('./utils');

module.exports = async (deployer, network, accounts) => {
    let market;

    return deployer
        .then(_ => deployer.deploy(Market))
        .then(_ => Market.deployed())
        .then(m => {
            market = m;
            return saveAddressToFile(deployer.basePath, 'PandoraMarket.json', JSON.stringify(market.address));
        })
        .catch(console.error);
};
