'use strict';

const Migrations = artifacts.require('Migrations');

const checkBalance = account => new Promise((resolve, reject) => {
    web3.eth.getBalance(account, (err, result) => {

        if (err) {
            return reject(err);
        }

        resolve(result.toNumber());
    });
});

module.exports = (deployer, network, accounts) => {

    // average amount of funds required to make migrations is 1.8 - 2
    // so set the minimum required fumds to the 3 eth
    // this amount should be enough
    return checkBalance(accounts[0])
        .then(accountBalance => {

            if (web3.fromWei(accountBalance, 'ether') < 3) {

                return Promise.reject(new Error('Your account is possibly has insufficient funds to make migrations'));
            }

            return Promise.resolve();
        })
        .then(_ => deployer.deploy(Migrations))
        .catch(err => {
            throw err;
        });
};
