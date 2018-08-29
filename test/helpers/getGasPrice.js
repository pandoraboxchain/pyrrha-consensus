module.exports = () => new Promise((resolve, reject) => {
    web3.eth.getGasPrice((err, balance) => {
        if (err) {
            reject(err);
        } else {
            resolve(balance);
        }
    });
});