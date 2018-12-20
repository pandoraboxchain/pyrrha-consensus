const WorkerNode = artifacts.require('WorkerNode');

module.exports.createWorkerNode = async (pandora, owner, computingPrice = 1000000000000000000) => {
    await pandora.whitelistWorkerOwner(owner);
    const nodeId = await pandora.workerNodesCount();

    await pandora.createWorkerNode(computingPrice, {from: owner});

    const idleWorkerAddress = await pandora.workerNodes(nodeId.toNumber());

    return await WorkerNode.at(idleWorkerAddress);
};