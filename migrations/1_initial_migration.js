'use strict';

const Migrations = artifacts.require('Migrations');

module.exports = (deployer, network, accounts) => {

  // average amount of funds required to make migrations is 1.8 - 2
  // so set the minimum required fumds to the 3 eth
  // this amount should be enough
  if (web3.fromWei(web3.eth.getBalance(accounts[0]).toNumber(10), 'ether') < 3) {

    throw new Error('Your account is possibly has insufficient funds to make migrations');
  }

  return deployer.deploy(Migrations);
};
