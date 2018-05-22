const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

contract('Pandora', accounts => {

    let datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    let kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

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

        // create worker node #1 first and set state to 'idle'

        const idleWorkerAddress = await pandora.workerNodes.call(0);
        // console.log(idleWorkerAddress, 'worker node');

        workerInstance = await WorkerNode.at(idleWorkerAddress);
        let workerAliveResult = await workerInstance.alive({
            from: workerOwner
        });
    });

    it.skip('Worker node should request cognitive job from queue when computation is finished', async () => {

        // console.log('Create cognitive job #1 with 2 batches to put it in queue');

        const numberOfBatches = 2;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, 0, numberOfBatches, 0);
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 0, 0);
        const estimatedCode = 0;

        const result = await pandora.createCognitiveJob(testKernel.address, testDataset.address);

        assert.equal(result.logs[0].args.resultCode.toNumber(), estimatedCode, 'result code in event should match RESULT_CODE_ADD_TO_QUEUE');

        const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];

        assert.isOk(logFailure, 'should be fired failed event');
        assert.isNotOk(logSuccess, 'should not be fired successful creation event');

        // console.log('Create cognitive job #2 for computing with 1 worker');

        const numberOfBatches2 = 1;
        const testDataset2 = await Dataset.new(datasetIpfsAddress, 1, 0, numberOfBatches2, 0);
        const testKernel2 = await Kernel.new(kernelIpfsAddress, 1, 0, 0);
        const estimatedCode2 = 1;

        const result2 = await pandora.createCognitiveJob(testKernel2.address, testDataset2.address);
        let activeJob = await workerInstance.activeJob.call();
        let workerState = await workerInstance.currentState.call();

        assert.equal(workerState.toNumber(), 3, `worker state should be "assigned" (3)`);
        assert.notEqual(activeJob, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node');
        assert.equal(result2.logs[1].args.resultCode, estimatedCode2, 'result code in event should match RESULT_CODE_JOB_CREATED');

        // console.log('Setup 2 additional worker nodes, so they could take queued job after any current job being finished');

        //#2
        await pandora.whitelistWorkerOwner(workerOwner1);
        workerNode1 = await pandora.createWorkerNode({
            from: workerOwner1
        });
        const idleWorkerAddress1 = await pandora.workerNodes.call(1);
        // console.log(idleWorkerAddress1, 'worker node1');
        workerInstance1 = await WorkerNode.at(idleWorkerAddress1);
        const workerAliveResult1 = await workerInstance1.alive({
            from: workerOwner1
        });

        //#3
        await pandora.whitelistWorkerOwner(workerOwner2);
        workerNode2 = await pandora.createWorkerNode({
            from: workerOwner2
        });
        const idleWorkerAddress2 = await pandora.workerNodes.call(2);
        // console.log(idleWorkerAddress2, 'worker node2');
        workerInstance2 = await WorkerNode.at(idleWorkerAddress2);
        const workerAliveResult2 = await workerInstance2.alive({
            from: workerOwner2
        });

        // console.log('Preparing to finish job on worker node #1');

        activeJob = await workerInstance.activeJob.call();
        // console.log(activeJob, 'activeJob #0');

        workerState = await workerInstance.currentState.call();
        // console.log(workerState.toNumber(), 'worker #0 state');

        const preparingValidationResult = await workerInstance.acceptAssignment({
            from: workerOwner
        });
        // console.log(preparingValidationResult)

        const validatingDataResult = await workerInstance.processToDataValidation({
            from: workerOwner
        });
        // console.log(validatingDataResult)

        const readyForComputingResult = await workerInstance.acceptValidData({
            from: workerOwner
        });
        // console.log(readyForComputingResult)

        const processToCognitionResult = await workerInstance.processToCognition({
            from: workerOwner
        });
        // console.log(processToCognitionResult)

        workerState = await workerInstance.currentState.call();
        // console.log(workerState.toNumber(), 'worker #0 state');
        assert.equal(workerState.toNumber(), 7, `worker state should be "computing" (7)`);

        activeJob = await workerInstance.activeJob.call();
        // console.log(activeJob, 'activeJob #0');


        const activeJobInstance = await CognitiveJob.at(activeJob);
        let results = await activeJobInstance.ipfsResultsCount.call()
        console.log("ipfsResults count: " + results.toNumber())
        // const jobBatches = await activeJobInstance.batches.call();
        // console.log(jobBatches.toNumber(), 'batches in active job #0');

        const jobWorkers = await activeJobInstance.activeWorkers.call(0);
        // console.log(jobWorkers, 'active workers in active job #0');

        // after providing results should be called _checkQueue() with queue logic
        //where congitiveJob created from queue and assigned to workers

        const completeResult = await workerInstance.provideResults('0x0', {
            from: workerOwner
        });
        // console.log(completeResult)

        // // console.log(workerState.toNumber(), 'worker #0 state');

        // const jobState = await CognitiveJob.at(activeJob).currentState.call();
        // // console.log(jobState.toNumber(), 'activeJob #0 state');
        // assert.equal(jobState.toNumber(), 7, `Cognitive job (#1) state should be "Completed" (7)`);

        // // check that 2 idle workers assigned to job
        // const workerState1 = await workerInstance1.currentState.call();
        // const activeJob1 = await workerInstance1.activeJob.call();

        // // console.log(workerState1.toNumber(), 'worker #1 state');

        // assert.equal(workerState1.toNumber(), 3, `worker state should be "assigned" (3)`);
        // assert.notEqual(activeJob1, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node 1');

        // const workerState2 = await workerInstance2.currentState.call();
        // const activeJob2 = await workerInstance2.activeJob.call();

        // assert.equal(workerState2.toNumber(), 3, `worker state should be "assigned" (3)`);
        // assert.notEqual(activeJob2, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node 2');

        // // console.log(workerState2.toNumber(), 'worker #2 state');
    });
});
