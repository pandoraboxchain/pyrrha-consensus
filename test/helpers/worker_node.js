module.exports.aliveWorker = async (worker, owner) => {
    return await worker.alive({from: owner});
};

module.exports.desctroyWorker = async (worker, owner) => {
    return await worker.destroy({from: owner});
};