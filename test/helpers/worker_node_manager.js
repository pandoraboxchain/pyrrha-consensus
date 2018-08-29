const WorkerNode = artifacts.require('WorkerNode');

module.exports.createWorkerNode = async (pandora, owner) => {
    await pandora.whitelistWorkerOwner(owner);
    const nodeId = await pandora.workerNodesCount();

    await pandora.createWorkerNode({from: owner});

    const idleWorkerAddress = await pandora.workerNodes.call(nodeId.toNumber());

    return await WorkerNode.at(idleWorkerAddress);
};