const assertRevert = require('./helpers/assertRevert');
const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

contract('Pandora', accounts => {

    const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

    let pandora;
    let pandoraAddress;
    let pandoraAddress1;
    let pandoraAddress2;
    let workerNode;
    let workerNode1;
    let workerNode2;
    let workerInstance;
    let workerInstance1;
    let workerInstance2;

    const workerOwner = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const client = accounts[5];

    before('setup', async () => {

        pandora = await Pandora.deployed();

        await pandora.whitelistWorkerOwner(workerOwner);
        workerNode = await pandora.createWorkerNode({
            from: workerOwner
        });

        const idleWorkerAddress = await pandora.workerNodes.call(0);

        // console.log(idleWorkerAddress, 'worker node');

        workerInstance = await WorkerNode.at(idleWorkerAddress);
        const workerAliveResult = await workerInstance.alive({
            from: workerOwner
        });
    });

    it('should not create cognitive contract from outside of Pandora', async () => {

        const numberOfBatches = 2;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, 0, numberOfBatches, 0);
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 0, 0);
        
        assertRevert(CognitiveJob.new(pandora.address, testDataset.address, testKernel.address, [workerNode.address]));
    });

    it('Should not create job if # of idle workers < number of batches and put it to queue', async () => {
        
        const numberOfBatches = 2;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, 0, numberOfBatches, 0);
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 0, 0);
        const estimatedCode = 0;

        const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address);

        const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
        const logEntries = result.logs.length;

        // console.log(logFailure, 'failure');
        // console.log(logSuccess, 'success');
        // console.log(logEntries, 'entries');

        const activeJobsCount = await pandora.activeJobsCount();

        assert.equal(activeJobsCount.toNumber(), 0, 'activeJobsCount = 0');
        assert.equal(result.logs[0].args.resultCode, estimatedCode, 'result code in event should match RESULT_CODE_ADD_TO_QUEUE');
        assert.equal(logEntries, 1, 'should be fired only 1 event');
        assert.isOk(logFailure, 'should be fired failed event');
        assert.isNotOk(logSuccess, 'should not be fired successful creation event');
    });

    it('#isActiveJob to be falsy if job not exist', async () => {

        const isActiveJob = await pandora.isActiveJob('');
        assert.equal(isActiveJob, false, 'job is not in the jobAddresses list');
    });

    it('Should create job if number of idle workers >= number of batches in dataset', async () => {

        const numberOfBatches = 1;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, 0, numberOfBatches, 0);
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 0, 0);
        const estimatedCode = 1;

        const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address);

        const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
        const logEntries = result.logs.length;

        // console.log(logFailure, 'failure');
        // console.log(logSuccess, 'success');
        // console.log(logEntries, 'entries');

        const activeJob = await workerInstance.activeJob.call();

        const workerState = await workerInstance.currentState.call();

        const activeJobsCount = await pandora.activeJobsCount();

        assert.equal(activeJobsCount.toNumber(), 1, 'activeJobsCount = 1');
        assert.equal(workerState.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(activeJob, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node');
        assert.equal(result.logs[1].args.resultCode, estimatedCode, 'result code in event should match RESULT_CODE_JOB_CREATED');
        assert.equal(logEntries, 2, 'should be fired only 2 events');
        assert.isNotOk(logFailure, 'should not be fired failed event');
        assert.isOk(logSuccess, 'should be fired successful creation event');
    });

    it.skip('Congitive job should be successfully completed after computation', async () => {

        //preparing to finish job on worker node #1

        const activeJob = await workerInstance.activeJob.call();
        // console.log(activeJob, 'activeJob');

        let workerState = await workerInstance.currentState.call();
        // console.log(workerState.toNumber(), 'workerState');

        const preparingValidationResult = await workerInstance.acceptAssignment({
            from: workerOwner
        });
        // console.log(preparingValidationResult);

        const validatingDataResult = await workerInstance.processToDataValidation({
            from: workerOwner
        });
        // console.log(validatingDataResult);

        const readyForComputingResult = await workerInstance.acceptValidData({
            from: workerOwner
        });
        // console.log(readyForComputingResult);

        const processToCognitionResult = await workerInstance.processToCognition({
            from: workerOwner
        });
        // console.log(processToCognitionResult);

        workerState = await workerInstance.currentState.call();
        // console.log(workerState.toNumber(), 'workerState');
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing" (7)`);

        const completeResult = await workerInstance.provideResults('0x0', {
            from: workerOwner
        });
        // console.log(completeResult)

        const logEntries = completeResult.logs.length;
        // console.log(logEntries);

        workerState = await workerInstance.currentState.call();
        // console.log(workerState.toNumber(), 'workerState');

        const jobState = await CognitiveJob.at(activeJob).currentState.call();
        // console.log(jobState.toNumber(), 'Active job state');
        assert.equal(jobState.toNumber(), 7, `Cognitive job state should be "Completed" (7)`);
    });
});
