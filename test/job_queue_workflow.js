const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
// const CognitiveJob = artifacts.require('CognitiveJob');

const assertRevert = require('./helpers/assertRevert');

contract('CognitiveJobQueue', accounts => {

    let datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    let kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

    let pandora;

    let workerNode;
    let workerNode1;
    let workerNode2;
    let workerInstance0;
    let workerInstance1;
    let workerInstance2;

    const workerOwner0 = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const customer = accounts[5];

    before('setup test job queue workflow', async () => {

        pandora = await Pandora.deployed();

        await pandora.whitelistWorkerOwner(workerOwner0);
        workerNode = await pandora.createWorkerNode({
            from: workerOwner0
        });

        // create worker node #1 first and set state to 'idle'

        const idleWorkerAddress = await pandora.workerNodes.call(0);
        // console.log(idleWorkerAddress, 'worker node');

        workerInstance0 = await WorkerNode.at(idleWorkerAddress);
        let workerAliveResult = await workerInstance0.alive({
            from: workerOwner0
        });
    });

    it.skip('Worker node should request cognitive job from queue when computation is finished', async () => {

        // console.log('Create cognitive job #1 with 3 batches to put it in queue');

        const numberOfBatches = 3;
        const testDataset = await Dataset.new(datasetIpfsAddress, 784, numberOfBatches, 48, "CIFAR_10,HENDWRITTEN,DIGITS", "CIFAR10,digits");
        const testKernel = await Kernel.new(kernelIpfsAddress, 784, 669706, 48, "CIFAR_10,HENDWRITTEN,DIGITS", "CIFAR10,digits,mode");
        const estimatedCode = 0;

        const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address, 669706, "1hendwriten digits train", {value: web3.toWei(0.5)});

        assert.equal(result.logs[0].args.resultCode, estimatedCode, 'result code in event should match RESULT_CODE_ADD_TO_QUEUE');

        const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];

        assert.isOk(logFailure, 'should be fired failed event');
        assert.isNotOk(logSuccess, 'should not be fired successful creation event');

        // Create cognitive job #2 for computing with 1 worker
        const numberOfBatches2 = 1;
        const testDataset2 = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches2, 0, "m-a", "d-n");
        const testKernel2 = await Kernel.new(kernelIpfsAddress, 1, 0, 0, "m-a", "d-n");
        const estimatedCode2 = 1;

        const result2 = await pandora.createCognitiveJob(testKernel2.address, testDataset2.address, 100, "d-n", {value: web3.toWei(0.5)});
        let cognitiveJob1Batch = await workerInstance0.activeJob.call();
        let workerState = await workerInstance0.currentState.call();

        assert.equal(workerState.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(cognitiveJob1Batch, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node');
        assert.equal(result2.logs[1].args.resultCode, estimatedCode2, 'result code in event should match RESULT_CODE_JOB_CREATED');

        // Setup 2 additional worker nodes, so they could take queued job after any current job being finished;

        //#2
        await pandora.whitelistWorkerOwner(workerOwner1);
        workerNode1 = await pandora.createWorkerNode({from: workerOwner1});

        const idleWorkerAddress1 = await pandora.workerNodes.call(1);
        workerInstance1 = await WorkerNode.at(idleWorkerAddress1);

        await workerInstance1.alive({from: workerOwner1});

        //#3
        await pandora.whitelistWorkerOwner(workerOwner2);
        workerNode2 = await pandora.createWorkerNode({from: workerOwner2});

        const idleWorkerAddress2 = await pandora.workerNodes.call(2);
        workerInstance2 = await WorkerNode.at(idleWorkerAddress2);

        await workerInstance2.alive({from: workerOwner2});

        //Preparing to finish job on worker node #1;

        await workerInstance0.acceptAssignment({from: workerOwner0});
        await workerInstance0.processToDataValidation({from: workerOwner0});
        await workerInstance0.acceptValidData({from: workerOwner0});

        await workerInstance0.processToCognition({from: workerOwner0});

        const activeJobInstance1Batch = await CognitiveJob.at(cognitiveJob1Batch);

        const jobBatches = await activeJobInstance1Batch.batches.call();
        assert.equal(jobBatches.toNumber(), 1, "batches in job should match");

        await workerInstance0.provideResults('0x01', {from: workerOwner0});

        let jobState = await CognitiveJob.at(cognitiveJob1Batch).currentState.call();
        assert.equal(jobState.toNumber(), 7, `Cognitive job (#1) state should be "Completed" (7)`);

        //here worker returns to Idle state and checks queue
        await pandora.unlockFinalizedWorker(cognitiveJob1Batch, {from: workerOwner0});

        // check that all 3 idle workers assigned to job
        const workerState0 = await workerInstance0.currentState.call();
        const activeJob0 = await workerInstance0.activeJob.call();

        assert.equal(workerState0.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(activeJob0, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node 1');

        const workerState1 = await workerInstance1.currentState.call();
        const activeJob1 = await workerInstance1.activeJob.call();

        assert.equal(workerState1.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(activeJob1, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node 1');

        const workerState2 = await workerInstance2.currentState.call();
        const cognitiveJob3Batches = await workerInstance2.activeJob.call();

        assert.equal(workerState2.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(cognitiveJob3Batches, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node 2');

        //completing job from queue

        await workerInstance0.acceptAssignment({from: workerOwner0});
        await workerInstance1.acceptAssignment({from: workerOwner1});
        await workerInstance2.acceptAssignment({from: workerOwner2});

        await workerInstance0.processToDataValidation({from: workerOwner0});
        await workerInstance1.processToDataValidation({from: workerOwner1});
        await workerInstance2.processToDataValidation({from: workerOwner2});

        await workerInstance0.acceptValidData({from: workerOwner0});
        await workerInstance1.acceptValidData({from: workerOwner1});
        await workerInstance2.acceptValidData({from: workerOwner2});

        jobState = await CognitiveJob.at(cognitiveJob3Batches).currentState.call();
        assert.equal(jobState.toNumber(), 5, `Cognitive job state should be "Cognition" (5)`);

        await workerInstance0.processToCognition({from: workerOwner0});
        await workerInstance1.processToCognition({from: workerOwner1});
        await workerInstance2.processToCognition({from: workerOwner2});

        workerState = await workerInstance0.currentState.call();
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing" (7)`);
        workerState = await workerInstance1.currentState.call();
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing" (7)`);
        workerState = await workerInstance2.currentState.call();
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing" (7)`);

        await workerInstance0.provideResults('0x01', {from: workerOwner0});
        await workerInstance1.provideResults('0x01', {from: workerOwner1});
        await workerInstance2.provideResults('0x01', {from: workerOwner2});

        await pandora.unlockFinalizedWorker(cognitiveJob3Batches, {from: workerOwner2});

        workerState = await workerInstance0.currentState.call();
        assert.equal(workerState.toNumber(), 2, `worker state should be "idle" (2)`);
        workerState = await workerInstance1.currentState.call();
        assert.equal(workerState.toNumber(), 2, `worker state should be "idle" (2)`);
        workerState = await workerInstance2.currentState.call();
        assert.equal(workerState.toNumber(), 2, `worker state should be "idle" (2)`);

        //check that job have been finished correctly
        jobState = await CognitiveJob.at(cognitiveJob3Batches).currentState.call();
        assert.equal(jobState.toNumber(), 7, `Cognitive job (#1) state should be "Completed" (7)`);
    });
});
