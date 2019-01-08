const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-bignumber')(BigNumber))
    .should();

const { assertRevert, eventFired } = require('./helpers');
const { createWorkerNode } =  require("./helpers/worker_node_manager");
const {
    finishActiveJob,
    createCognitiveJob,
} = require("./helpers/cognitive_job_manager");
const { aliveWorker } = require("./helpers/worker_node");
const toPan = require('./helpers/toPan');
const deployAll = require('./helpers/deployAll');

const WorkerNode = artifacts.require('WorkerNode');
const Kernel = artifacts.require('Kernel');
const Dataset = artifacts.require('Dataset');

contract('WorkerNode', (
    [owner1, owner2, owner3, owner4, owner5, 
    owner6, owner7, owner8, owner9, owner10,
    owner11, owner12, owner13, owner14, owner15]
) => {

    const funds50 = toPan(50);
    const funds200 = toPan(200);
    const computingPrice = toPan(1);

    let pandora;
    let pan;
    let economicController;
    let jobController;
    let minStake;

    beforeEach('setup', async () => {

        const contracts = await deployAll(owner1);
        pan = contracts.pan;
        pandora = contracts.pandora;
        jobController = contracts.jobController;
        economicController = contracts.economicController;

        minStake = await economicController.minimumWorkerNodeStake();
        await pan.transfer(owner2, funds200, { from: owner1 });
        await pan.transfer(owner3, funds200, { from: owner1 });
        await pan.transfer(owner4, funds50, { from: owner1 });
        await pan.transfer(owner5, funds200, { from: owner1 });
        await pan.transfer(owner6, funds200, { from: owner1 });
        await pan.transfer(owner7, funds200, { from: owner1 });
        await pan.transfer(owner8, funds200, { from: owner1 });
        await pan.transfer(owner9, funds200, { from: owner1 });
        await pan.transfer(owner10, funds200, { from: owner1 });
        await pan.transfer(owner11, funds200, { from: owner1 });
        await pan.transfer(owner12, funds200, { from: owner1 });
        await pan.transfer(owner13, funds200, { from: owner1 });
        await pan.transfer(owner14, funds200, { from: owner1 });
        await pan.transfer(owner15, funds200, { from: owner1 });
    });

    describe('#updateComputingPrice', () => {

        it('should update computing price', async () => {
            const workerNode = await createWorkerNode(pandora, owner7, computingPrice, pan, economicController);
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
            await pan.approve(economicController.address, minStake, {from: owner3});
            await pandora.createWorkerNode(computingPrice, {from: owner3});
            const wnAddress = await pandora.workerNodes(nodeId.toNumber());
            (await WorkerNode.at(wnAddress).currentState()).should.be.bignumber.equal(1);
        });

        it('should fail if worker not whitelisted', async () => {
            await pan.approve(economicController.address, minStake, {from: owner5});
            await assertRevert(pandora.createWorkerNode(computingPrice, {from: owner5}));
        });

        it('should fail if worker has insufficient stake', async () => {
            await pandora.whitelistWorkerOwner(owner4);
            await pan.approve(economicController.address, minStake, {from: owner4});
            await assertRevert(pandora.createWorkerNode(computingPrice, {from: owner4}));
        });

        it('should fail if computingPrice less then 1', async () => {
            await pandora.whitelistWorkerOwner(owner5);
            await pan.approve(economicController.address, minStake, {from: owner5});
            await assertRevert(pandora.createWorkerNode(0, {from: owner5}));
        });
    });

    describe('#aliveWorker', () => {

        it('should move worker to iddle state', async () => {
            const workerNode = await createWorkerNode(pandora, owner2, computingPrice, pan, economicController);
            await workerNode.alive({from: owner2});
            (await workerNode.currentState()).should.be.bignumber.equal(2);
            await workerNode.offline({from: owner2});// back to offline
        });
    });

    describe("Full workflow", () => {

        it("should transit thru all states", async () => {
            const wrongOwner = owner4;
            const workerNodeOwner = owner5;
            const jobOwner = owner6;
            const datasetOwner = owner7;
            const kernelOwner = owner8;

            // get current system commission and minimumWorkerNodeStake
            const systemCommission = (await economicController.systemCommission()).toNumber();

            // get initial system balance (pandoraOwner)
            const initialSytemBalance = (await pan.balanceOf(pandora.address)).toNumber();

            // Create worker node
            const workerNode = await createWorkerNode(pandora, workerNodeOwner, computingPrice, pan, economicController);

            // get initial worker node balance
            const initialWorkerNodeBalance = (await pan.balanceOf(workerNodeOwner)).toNumber();

            // get worker node price (max)
            const workerNodePrice = (await pandora.getMaximumWorkerPrice()).toNumber();
            
            // transit worker node to state Alive
            await workerNode.alive({from: workerNodeOwner});

            // Create job
            const batchesCount = 1;
            const jobTx = await createCognitiveJob(pandora, batchesCount, {}, pan, economicController, jobOwner, datasetOwner, kernelOwner);
            const jobId = jobTx.logs[0].args.jobId;
            const jobDetails = await jobController.getCognitiveJobDetails(jobId);
            //console.log(jobDetails);
            const kernel = jobDetails[1];
            const dataset = jobDetails[2];
            const kernelPrice = (await Kernel.at(kernel).currentPrice()).toNumber();
            const datasetPrice = (await Dataset.at(dataset).currentPrice()).toNumber();

            // calculate total job price
            const totalJobPrice = kernelPrice + datasetPrice + (workerNodePrice * batchesCount);
            
            // Check blocked funds of jobOwner
            (await economicController.balanceOf(jobOwner)).should.be.bignumber.equal(totalJobPrice);

            // Check initial token balance of kernel and database owners
            (await pan.balanceOf(kernelOwner)).should.be.bignumber.equal(funds200);
            (await pan.balanceOf(datasetOwner)).should.be.bignumber.equal(funds200);

            // state should be Assigned after job creation
            (await workerNode.currentState()).should.be.bignumber.equal(3);

            // transit to state ReadyForDataValidation
            await assertRevert(workerNode.acceptAssignment({from: wrongOwner}), '#acceptAssignment');// should fail with wrong owner
            await workerNode.acceptAssignment({from: workerNodeOwner});
            (await workerNode.currentState()).should.be.bignumber.equal(4);

            // transit to state ValidatingData
            await assertRevert(workerNode.processToDataValidation({from: wrongOwner}), '#processToDataValidation');// should fail with wrong owner
            await workerNode.processToDataValidation({from: workerNodeOwner});
            (await workerNode.currentState()).should.be.bignumber.equal(5);

            // transit to state ReadyForComputing
            await assertRevert(workerNode.acceptValidData({from: wrongOwner})), '#acceptValidData';// should fail with wrong owner
            await workerNode.acceptValidData({from: workerNodeOwner});
            (await workerNode.currentState()).should.be.bignumber.equal(6);

            // transit to state Computing
            await assertRevert(workerNode.processToCognition({from: wrongOwner}), '#processToCognition');// should fail with wrong owner
            await workerNode.processToCognition({from: workerNodeOwner});
            (await workerNode.currentState()).should.be.bignumber.equal(7);

            // provide job progress
            const progress_one = await workerNode.jobProgress();
            await assertRevert(workerNode.reportProgress(10, {from: wrongOwner}), '#reportProgress');// should fail with wrong owner
            await workerNode.reportProgress(10, {from: workerNodeOwner});            
            const progress_two = await workerNode.jobProgress();
            (progress_two).should.be.be.bignumber.gt(progress_one);

            // provide results
            await assertRevert(workerNode.provideResults(0x0, {from: wrongOwner}), '#provideResults');// should fail with wrong owner
            await workerNode.provideResults(0x0, {from: workerNodeOwner});

            // Check job rewards (kernel owner, dataset owner, worker node owner, system)
            (await pan.balanceOf(kernelOwner)).should.be.bignumber.equal(funds200 + (kernelPrice - (kernelPrice / 100 * systemCommission)));
            (await pan.balanceOf(datasetOwner)).should.be.bignumber.equal(funds200 + (datasetPrice - (datasetPrice / 100 * systemCommission)));
            (await pan.balanceOf(workerNodeOwner)).should.be.bignumber.equal(initialWorkerNodeBalance + (workerNodePrice - (workerNodePrice / 100 * systemCommission)));
            (await pan.balanceOf(pandora.address)).should.be.bignumber.equal(initialSytemBalance + (totalJobPrice / 100 * systemCommission));
            (await economicController.balanceOf(jobOwner)).should.be.bignumber.equal(0);// all blocked funds has been spent to rewards

            // transit to state Offline
            await assertRevert(workerNode.offline({from: wrongOwner}), '#transitionToState');// should fail with wrong owner
            await workerNode.offline({from: workerNodeOwner});

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

    describe('Worker node penalties', () => {

        it('OfflineWhileGathering', async () => {
            const workerNode1 = await createWorkerNode(pandora, owner8, computingPrice, pan, economicController);
            const workerNode2 = await createWorkerNode(pandora, owner9, computingPrice, pan, economicController);
            
            await workerNode1.alive({from: owner8});

            const stakeBefore = await economicController.balanceOf(owner9);

            await createCognitiveJob(pandora, 2, {}, pan, economicController, owner10, owner11, owner12);// owner7 should be penalized and loss a stake in amount of computingPrice

            (await economicController.balanceOf(owner9)).should.be.bignumber.equal(stakeBefore.toNumber() - computingPrice);
            
            const result = await eventFired(economicController, 'PenaltyApplied');
            const penaltyEvent = result.filter(l => (
                l.args.owner === owner9 
            ));  
            (penaltyEvent.length).should.equal(1);
            (penaltyEvent[0].args.reason).should.be.bignumber.equal(0);
            (penaltyEvent[0].args.value).should.be.bignumber.equal(computingPrice);
        });

        it('DeclinesJob', async () => {
            const workerNode1 = await createWorkerNode(pandora, owner10, computingPrice, pan, economicController);
            await workerNode1.alive({from: owner10});
            await createCognitiveJob(pandora, 1, {}, pan, economicController, owner10, owner11, owner12);
            const stakeBefore = await economicController.balanceOf(owner10);

            await workerNode1.declineAssignment({from: owner10});

            (await economicController.balanceOf(owner10)).should.be.bignumber.equal(stakeBefore.toNumber() - computingPrice);
            const result = await eventFired(economicController, 'PenaltyApplied');
            const penaltyEvent = result.filter(l => (
                l.args.owner === owner10 
            ));  
            (penaltyEvent.length).should.equal(1);
            (penaltyEvent[0].args.reason).should.be.bignumber.equal(1);
            (penaltyEvent[0].args.value).should.be.bignumber.equal(computingPrice);
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