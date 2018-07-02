const CognitiveJob = artifacts.require('CognitiveJob');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const { assign } = require("lodash");

const {
    WORKER_STATE_COMPUTING,
    WORKER_STATES,

    JOB_STATE_COMPLETED,
    JOB_STATES,
} = require("../constants");

const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

module.exports.datasetIpfsAddress = datasetIpfsAddress;
module.exports.kernelIpfsAddress = kernelIpfsAddress;

module.exports.finishActiveJob = async (pandora, workerInstance, workerOwner, opts) => {
    const activeJob = await workerInstance.activeJob.call();

    await workerInstance.acceptAssignment({from: workerOwner});
    await workerInstance.processToDataValidation({from: workerOwner});
    await workerInstance.acceptValidData({from: workerOwner});
    await workerInstance.processToCognition({from: workerOwner});

    const jobId = await pandora.jobAddresses(activeJob);
    const workerId = await pandora.workerAddresses(workerInstance.address);

    let workerState = await workerInstance.currentState.call();
    assert.equal(
        WORKER_STATES[workerState.toNumber()],
        WORKER_STATES[WORKER_STATE_COMPUTING],
        `Worker (${workerId}) state should be ${WORKER_STATES[WORKER_STATE_COMPUTING]} (${WORKER_STATE_COMPUTING})`);

    await workerInstance.provideResults('0x0', {from: workerOwner});
    await pandora.unlockFinalizedWorker(activeJob, {from: workerOwner});

    const jobState = await CognitiveJob.at(activeJob).currentState.call();
    assert.equal(
        JOB_STATES[jobState.toNumber()],
        JOB_STATES[JOB_STATE_COMPLETED],
        `Cognitive job (${jobId}) state should be ${JOB_STATES[JOB_STATE_COMPLETED]} (${JOB_STATE_COMPLETED})`);
};

module.exports.createCognitiveJob = async (pandora, batchesCount, opts = {}) => {
    const options = assign({}, {value: web3.toWei(0.5)}, opts);
    const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
    const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

    return await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", options);
}