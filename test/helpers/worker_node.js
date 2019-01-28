module.exports.aliveWorker = async (worker, owner, pan, controller) => {
    const minStake = await controller.minimumWorkerNodeStake();
    await pan.approve(controller.address, minStake, {from: owner});
    return await worker.alive({from: owner});
};

module.exports.desctroyWorker = async (worker, owner) => {
    return await worker.destroy({from: owner});
};