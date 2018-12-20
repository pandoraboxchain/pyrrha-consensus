const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();

const { assertRevert } = require('./helpers');
const { createWorkerNode } =  require("./helpers/worker_node_manager");
const {
    finishActiveJob,
    createCognitiveJob,
} = require("./helpers/cognitive_job_manager");
const { aliveWorker } = require("./helpers/worker_node");

const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');


contract('WorkerNode', ([owner1, owner2, owner3, owner4, owner5, owner6, owner7]) => {

    const funds200 = 200 * 1000000000000000000;
    const funds50 = 50 * 1000000000000000000;
    const computingPrice = 1 * 1000000000000000000;
    let pandora;

    before('setup', async () => {
        pandora = await Pandora.deployed();
        await pandora.transfer(owner2, funds200, { from: owner1 });
        await pandora.transfer(owner3, funds200, { from: owner1 });
        await pandora.transfer(owner4, funds50, { from: owner1 });
        await pandora.transfer(owner5, funds200, { from: owner1 });
        await pandora.transfer(owner6, funds200, { from: owner1 });
        await pandora.transfer(owner7, funds200, { from: owner1 });
    });

    describe('#updateComputingPrice', () => {

        it('should update computing price', async () => {
            await pandora.whitelistWorkerOwner(owner7);
            const workerNode = await createWorkerNode(pandora, owner7, computingPrice);
            (await workerNode.computingPrice()).should.be.bignumber.equal(computingPrice);
            const newPrice = computingPrice * 2;
            await workerNode.updateComputingPrice(newPrice, {from: owner7});
            (await workerNode.computingPrice()).should.be.bignumber.equal(newPrice);
        });
    });

    describe('#createWorkerNode', () => {

        it('should create a workerNode instance', async () => {
            await pandora.whitelistWorkerOwner(owner3);
            const nodeId = await pandora.workerNodesCount();
            await pandora.createWorkerNode(computingPrice, {from: owner3});
            const wnAddress = await pandora.workerNodes(nodeId.toNumber());
            (await WorkerNode.at(wnAddress).currentState()).should.be.bignumber.equal(1);
        });

        it('should fail if worker not whitelisted', async () => {
            await assertRevert(pandora.createWorkerNode(computingPrice, {from: owner4}));
        });

        it('should fail if worker has insufficient stake', async () => {
            await pandora.whitelistWorkerOwner(owner4);
            await assertRevert(pandora.createWorkerNode(computingPrice, {from: owner4}));
        });

        it('should fail if computingPrice less then 1', async () => {
            await pandora.whitelistWorkerOwner(owner4);
            await assertRevert(pandora.createWorkerNode(0, {from: owner4}));
        });
    });

    describe('#aliveWorker', () => {

        it('should move worker to iddle state', async () => {
            const workerNode = await createWorkerNode(pandora, owner2, computingPrice);
            await workerNode.alive({from: owner2});
            (await workerNode.currentState()).should.be.bignumber.equal(2);
            await workerNode.offline({from: owner2});// back to offline
        });
    });

    describe("Full cycle", () => {

        it("should transit thru all states", async () => {
            const workerNode = await createWorkerNode(pandora, owner5, computingPrice);
            
            // transit to state Alive
            await workerNode.alive({from: owner5});
            await createCognitiveJob(pandora, 1);

            // state should be Assigned after job creation
            (await workerNode.currentState()).should.be.bignumber.equal(3);

            // transit to state ReadyForDataValidation
            await assertRevert(workerNode.acceptAssignment({from: owner4}), '#acceptAssignment');// should fail with wrong owner
            await workerNode.acceptAssignment({from: owner5});
            (await workerNode.currentState()).should.be.bignumber.equal(4);

            // transit to state ValidatingData
            await assertRevert(workerNode.processToDataValidation({from: owner4}), '#processToDataValidation');// should fail with wrong owner
            await workerNode.processToDataValidation({from: owner5});
            (await workerNode.currentState()).should.be.bignumber.equal(5);

            // transit to state ReadyForComputing
            await assertRevert(workerNode.acceptValidData({from: owner4})), '#acceptValidData';// should fail with wrong owner
            await workerNode.acceptValidData({from: owner5});
            (await workerNode.currentState()).should.be.bignumber.equal(6);

            // transit to state Computing
            await assertRevert(workerNode.processToCognition({from: owner4}), '#processToCognition');// should fail with wrong owner
            await workerNode.processToCognition({from: owner5});
            (await workerNode.currentState()).should.be.bignumber.equal(7);

            // provide job progress
            const progress_one = await workerNode.jobProgress();
            await assertRevert(workerNode.reportProgress(10, {from: owner4}), '#reportProgress');// should fail with wrong owner
            await workerNode.reportProgress(10, {from: owner5});            
            const progress_two = await workerNode.jobProgress();
            (progress_two).should.be.be.bignumber.gt(progress_one);

            // provide results
            await assertRevert(workerNode.provideResults(0x0, {from: owner4}), '#provideResults');// should fail with wrong owner
            await workerNode.provideResults(0x0, {from: owner5});

            // transit to state Offline
            await assertRevert(workerNode.offline({from: owner4}), '#transitionToState');// should fail with wrong owner
            await workerNode.offline({from: owner5});

            // const workersCount = await pandora.workerNodesCount();
            // let wnAddress;
            // let wn;

            // for (let i = 0; i < workersCount.toNumber(); i++ ) {
            //     wnAddress = await pandora.workerNodes(i);
            //     wn = await WorkerNode.at(wnAddress);
            //     console.log('>>>', await wn.currentState());
            // }
        });        
    });

    describe("cancelJob", () => {

        // it.skip("should change active job progress", function (done) {
        //     let progress_one, timestamp_one, progress_two, timestamp_two, activeJobInstance;

        //     (async () => {
        //         activeJobInstance = await CognitiveJob.at(await workerInstance.activeJob());

        //         progress_one = await workerInstance.jobProgress();
        //         timestamp_one = await activeJobInstance.responseTimestamps(workerIndex);
        //     })();

        //     setTimeout(async () => {
        //         await workerInstance.reportProgress(++progress, {from: owner2});

        //         progress_two = await workerInstance.jobProgress();
        //         timestamp_two = await activeJobInstance.responseTimestamps(workerIndex);

        //         assert.notEqual(progress_one.toNumber(), progress_two.toNumber(), "Progress was not changed");
        //         assert.notEqual(timestamp_one.toNumber(), timestamp_two.toNumber(), "Job progress timestamp was not changed");
        //         done();
        //     }, 1000)
            
        // });
    });
    describe("acceptAssignment", () => {});
    describe("processToDataValidation", () => {});
    describe("acceptValidData", () => {});
    describe("processToCognition", () => {});
    describe("provideResults", () => {});

});