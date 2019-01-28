const WorkerNode = artifacts.require('WorkerNode');

module.exports.createWorkerNode = async (pandora, owner, computingPrice = 1000000000000000000, pan, controller) => {
    await pandora.whitelistWorkerOwner(owner);
    const nodeId = await pandora.workerNodesCount();
    const minStake = await controller.minimumWorkerNodeStake();
    await pan.approve(controller.address, minStake, {from: owner});
    await pandora.createWorkerNode(computingPrice, {from: owner});
    const idleWorkerAddress = await pandora.workerNodes(nodeId.toNumber());
    return await WorkerNode.at(idleWorkerAddress);
};