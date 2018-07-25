const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const { assign } = require("lodash");

const {
    WORKER_STATE_COMPUTING,
    WORKER_STATE_IDLE,
    WORKER_STATES,

    JOB_STATE_COMPLETED,
    JOB_STATES,
    EMPTY
} = require("../constants");

const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

module.exports.finishActiveJob = async (pandora, workerInstance, workerOwner, opts) => {
    const options = assign({}, {from: workerOwner}, opts);
    const activeJob = await workerInstance.activeJob.call();

    if (activeJob === EMPTY) return;

    // const activeJobState = await CognitiveJob.at(activeJob).currentState.call();

    // if (activeJobState.toNumber() !== JOB_STATE_COMPLETED) {
        await workerInstance.acceptAssignment(options);
        await workerInstance.processToDataValidation(options);
        await workerInstance.acceptValidData(options);
        await workerInstance.processToCognition(options);
        await workerInstance.provideResults('0x42', options);

        const workerState = await workerInstance.currentState.call();
        // const jobId = await pandora.jobAddresses(activeJob);
        //
        // if (workerState.toNumber() !== WORKER_STATE_IDLE) {
        //     await pandora.unlockFinalizedWorker(activeJob, options);

            // const jobState = await CognitiveJob.at(activeJob).currentState.call();
            // assert.equal(
            //     JOB_STATES[jobState.toNumber()],
            //     JOB_STATES[JOB_STATE_COMPLETED],
            //     `Cognitive job (${jobId}) state should be ${JOB_STATES[JOB_STATE_COMPLETED]} (${JOB_STATE_COMPLETED})`);
        // }
    // }
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