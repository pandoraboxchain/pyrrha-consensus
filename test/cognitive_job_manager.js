const assertRevert = require('./helpers/assertRevert');
const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

contract('CognitiveJobManager', accounts => {

    const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

    let pandora;

    let workerNode;
    let workerNode1;
    let workerNode2;
    let workerInstance;
    let workerInstance1;
    let workerInstance2;

    const workerOwner = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const customer = accounts[5];

    before('setup test cognitive job manager', async () => {

        pandora = await Pandora.deployed();

        await pandora.whitelistWorkerOwner(workerOwner);
        workerNode = await pandora.createWorkerNode({from: workerOwner});

        const idleWorkerAddress = await pandora.workerNodes.call(0);

        workerInstance = await WorkerNode.at(idleWorkerAddress);
        await workerInstance.alive({from: workerOwner});
    });

    it('should not create cognitive contract from outside of Pandora', async () => {

        const numberOfBatches = 2;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches, 0, "m-a", "d-n");
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

        assertRevert(CognitiveJob.new(
            pandora.address, testDataset.address, testKernel.address, [workerNode.address], 1, "d-n"));
    });

    it('Should not create job, and put it to queue if # of idle workers < number of batches', async () => {

        const batchesCount = 2;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");
        const estimatedCode = 0;

        const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});

        const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
        const logEntries = result.logs.length;

        const activeJobsCount = await pandora.cognitiveJobsCount();

        assert.equal(activeJobsCount.toNumber(), 0, 'activeJobsCount = 0');
        assert.equal(result.logs[0].args.resultCode, estimatedCode, 'result code in event should match RESULT_CODE_ADD_TO_QUEUE');
        assert.equal(logEntries, 1, 'should be fired only 1 event');
        assert.isOk(logFailure, 'should be fired failed event');
        assert.isNotOk(logSuccess, 'should not be fired successful creation event');
    });

    it('Congitive job should be successfully completed after computation', async () => {

        //preparing to finish job on worker node #1

        const batchesCount = 1;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

        await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});

        const activeJob = await workerInstance.activeJob.call();

        await workerInstance.acceptAssignment({from: workerOwner});
        await workerInstance.processToDataValidation({from: workerOwner});
        await workerInstance.acceptValidData({from: workerOwner});
        await workerInstance.processToCognition({from: workerOwner});

        let workerState = await workerInstance.currentState.call();
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing"`);

        await workerInstance.provideResults('0x0', {from: workerOwner});
        await pandora.unlockFinalizedWorker(activeJob, {from: workerOwner});

        workerState = await workerInstance.currentState.call();
        assert.equal(workerState.toNumber(), 2, `worker state should be "idle"`);

        const jobState = await CognitiveJob.at(activeJob).currentState.call();
        assert.equal(jobState.toNumber(), 7, `Cognitive job state should be "Completed"`);
    });

    it('Should create job if number of idle workers >= number of batches in dataset and complete it', async () => {

        const numberOfBatches = 1;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches, 10, "m-a", "d-n");
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");
        const estimatedCode = 1;

        //lets create 30 jobs and finish them
        for (let i = 0; i < 30; i++) {

            const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});

            const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
            const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
            let logEntries = result.logs.length;

            let activeJob = await workerInstance.activeJob.call();
            let workerState = await workerInstance.currentState.call();
            const activeJobsCount = await pandora.cognitiveJobsCount();

            assert.equal(activeJobsCount.toNumber(), i + 2, 'activeJobsCount should increase');
            assert.equal(workerState.toNumber(), 3, `worker state should be "assigned"`);
            assert.notEqual(activeJob, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node');
            assert.equal(result.logs[1].args.resultCode, estimatedCode, 'result code in event should match RESULT_CODE_JOB_CREATED');
            assert.equal(logEntries, 2, 'should be fired only 2 events');
            assert.isNotOk(logFailure, 'should not be fired failed event');
            assert.isOk(logSuccess, 'should be fired successful creation event');

            activeJob = await workerInstance.activeJob.call();

            await workerInstance.acceptAssignment({from: workerOwner});
            await workerInstance.processToDataValidation({from: workerOwner});
            await workerInstance.acceptValidData({from: workerOwner});
            await workerInstance.processToCognition({from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 7, `worker state should be "computing"`);

            const completeResult = await workerInstance.provideResults('0x0', {from: workerOwner});
            await pandora.unlockFinalizedWorker(activeJob, {from: workerOwner});

            logEntries = completeResult.logs.length;

            workerState = await workerInstance.currentState.call();

            const jobState = await CognitiveJob.at(activeJob).currentState.call();
            assert.equal(jobState.toNumber(), 7, `Cognitive job state should be "Completed")`);
        }
    });

    it('#isActiveJob to be falsy if job not exist', async () => {

        const isActiveJob = await pandora.isActiveJob('');
        assert.equal(isActiveJob, false, 'job is not in the jobAddresses list');
    });

});
