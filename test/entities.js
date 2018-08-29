const assertRevert = require('./helpers/assertRevert');
const Pandora = artifacts.require('Pandora');
const CognitiveJobController = artifacts.require('CognitiveJobController');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const DataEntity = artifacts.require('DataEntity');

const Web3latest = require('web3');
const web3latest = new Web3latest();

contract.skip('Entities', accounts => {

    const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

    let pandora;
    let jobController;

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

    before('setup test entities', async () => {

        jobController = await CognitiveJobController.deployed();
        pandora = await Pandora.deployed();

        await pandora.whitelistWorkerOwner(workerOwner);
        workerNode = await pandora.createWorkerNode({from: workerOwner});

        const idleWorkerAddress = await pandora.workerNodes.call(0);

        workerInstance = await WorkerNode.at(idleWorkerAddress);
        await workerInstance.alive({from: workerOwner});
    });

    describe('WorkerNode', async () => {

        it('should properly change states during computations', async () => {

            const batchesCount = 1;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

            let workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 2, `worker state should be "Idle"`);

            await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});
            const activeJobInstance = await workerInstance.activeJob.call();

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 3, `worker state should be "Assigned"`);

            await workerInstance.acceptAssignment({from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 4, `worker state should be "ReadyForDataValidation"`);

            await workerInstance.processToDataValidation({from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 5, `worker state should be "ValidatingData"`);

            await workerInstance.acceptValidData({from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 6, `worker state should be "ReadyForComputing"`);

            await workerInstance.processToCognition({from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 7, `worker state should be "Computing"`);

            await workerInstance.provideResults('0x0', {from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 7, `worker state should be "Computing"`);

            await pandora.unlockFinalizedWorker(activeJobInstance, {from: workerOwner});

            workerState = await workerInstance.currentState.call();
            assert.equal(workerState.toNumber(), 2, `worker state should be "Idle"`);

            const jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 7, `Cognitive job state should be "Completed"`);
        });
    });

    describe('CognitiveJob', async () => {

        it('should properly change states during computations', async () => {

            //add one more worker
            workerNode = await pandora.createWorkerNode({from: workerOwner});
            const workerAddress = await pandora.workerNodes.call(1);
            workerInstance1 = await WorkerNode.at(workerAddress);
            await workerInstance1.alive({from: workerOwner});

            const batchesCount = 2;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

            await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});
            const activeJobInstance = await workerInstance.activeJob.call();

            let jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 1, `Cognitive job state should be "GatheringWorkers"`);

            await workerInstance.acceptAssignment({from: workerOwner});
            await workerInstance1.acceptAssignment({from: workerOwner});

            jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 3, `Cognitive job state should be "DataValidation"`);

            await workerInstance.processToDataValidation({from: workerOwner});
            await workerInstance1.processToDataValidation({from: workerOwner});

            jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 3, `Cognitive job state should be "DataValidation"`);

            await workerInstance.acceptValidData({from: workerOwner});
            await workerInstance1.acceptValidData({from: workerOwner});

            jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 5, `Cognitive job state should be "Cognition"`);

            await workerInstance.processToCognition({from: workerOwner});
            await workerInstance1.processToCognition({from: workerOwner});

            jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 5, `Cognitive job state should be "Cognition"`);

            await workerInstance.provideResults('0x01', {from: workerOwner});

            assertRevert(pandora.unlockFinalizedWorker(activeJobInstance, {from: workerOwner}));

            await workerInstance1.provideResults('0x01', {from: workerOwner});

            await pandora.unlockFinalizedWorker(activeJobInstance, {from: workerOwner});

            jobState = await CognitiveJob.at(activeJobInstance).currentState.call();
            assert.equal(jobState.toNumber(), 7, `Cognitive job (#1) state should be "Completed" (7)`);
        });
    });

    describe('DataEntity', async () => {

        it('price should be updated correctly', async () => {

            let initialPrice = 100;
            let newPrice = 10000;
            const testDataEntity = await DataEntity.new(datasetIpfsAddress, 1, initialPrice);
            await testDataEntity.updatePrice(newPrice);
            let actualPrice = await testDataEntity.currentPrice.call();
            assert.equal(actualPrice.toNumber(), newPrice, "price should be updated")
        });

        it('should withdraw funds correctly', async () => {

            let value = 100000;
            const testDataEntity = await DataEntity.new(datasetIpfsAddress, 1, 100, {from: customer, value: value});

            let dataEntityBalance = await web3.eth.getBalance(testDataEntity.address);
            assert.equal(dataEntityBalance.toNumber(), value, "balance should be increased")

            await testDataEntity.withdrawBalance({from: customer});

            dataEntityBalance = await web3.eth.getBalance(testDataEntity.address);
            assert.equal(dataEntityBalance.toNumber(), 0, "balance should be 0");
        });
    });
});