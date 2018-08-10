const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const { assign } = require("lodash");

const {
    WORKER_STATE_IDLE,
    WORKER_STATE_UNINITIALIZED,
    WORKER_STATE_OFFLINE,
    WORKER_STATE_ASSIGNED,
    WORKER_STATE_READYFORDATAVALIDATION,
    WORKER_STATE_VALIDATINGDATA,
    WORKER_STATE_READYFORCOMPUTING,
    WORKER_STATE_COMPUTING,

    JOB_STATE_COMPLETED,
    JOB_STATES,
    EMPTY
} = require("../constants");

const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

module.exports.acceptAssignment = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();
    if (activeJob === EMPTY) return;
    await workerInstance.acceptAssignment(options);

    const workerState = await workerInstance.currentState.call();
    assert.equal(workerState, WORKER_STATE_READYFORDATAVALIDATION);
};

module.exports.processToDataValidation = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();

    if (activeJob === EMPTY) return;
    await workerInstance.processToDataValidation(options);

    const workerState = await workerInstance.currentState.call();
    assert.equal(workerState, WORKER_STATE_VALIDATINGDATA);
};

module.exports.acceptValidData = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();

    if (activeJob === EMPTY) return;
    await workerInstance.acceptValidData(options);

    const workerState = await workerInstance.currentState.call();
    assert.equal(workerState, WORKER_STATE_READYFORCOMPUTING);
};

module.exports.processToCognition = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();

    if (activeJob === EMPTY) return;
    await workerInstance.processToCognition(options);

    const workerState = await workerInstance.currentState.call();
    assert.equal(workerState, WORKER_STATE_COMPUTING);
};

module.exports.provideResults = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();

    if (activeJob === EMPTY) return;
    await workerInstance.provideResults('0x42', options);

    const workerState = await workerInstance.currentState.call();
    assert.equal(workerState, WORKER_STATE_IDLE);
};

module.exports.createCognitiveJob = async (pandora, batchesCount, opts = {}) => {
    const options = assign({}, {value: web3.toWei(0.5)}, opts);
    const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
    const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

    return await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", options);
};

module.exports.getQueueDepth = async (pandora) => {
    const queue = await pandora.getQueueDepth.call();
    if (queue) {
        return queue.toNumber();
    } else {
        return 0;
    }
};

module.exports.checkJobQueue = async (pandora) => {
    return await pandora.checkJobQueue.call();
};

module.exports.datasetIpfsAddress = datasetIpfsAddress;
module.exports.kernelIpfsAddress = kernelIpfsAddress;