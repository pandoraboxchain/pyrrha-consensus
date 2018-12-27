module.exports = (target, eventName) => new Promise((resolve, reject) => {

    target[eventName]({}, {fromBlock: 0}).get((err, result) => {

        if (err) {
            return reject(err);
        }

        result.length > 0 ? resolve(result) : reject(new Error(`Event "${eventName}" not fired`));
    });
});
