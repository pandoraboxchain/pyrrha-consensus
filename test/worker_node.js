const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
// const CognitiveJob = artifacts.require('CognitiveJob');

const {
    assertRevert,
} = require('./helpers');

const {
    createWorkerNode,
} =  require("./helpers/worker_node_manager");

const {
    finishActiveJob,
    createCognitiveJob,
} = require("./helpers/cognitive_job_manager");

const {
    aliveWorker
} = require("./helpers/worker_node");

contract('WorkerNode', accounts => {

    let pandora;

    let workerIndex = 0;

    let workerOwner = accounts[1];

    let workerInstance;

    before('setup', async () => {

        pandora = await Pandora.deployed();

        workerInstance = await createWorkerNode(pandora, workerOwner);
        await aliveWorker(workerInstance, workerOwner);

        await createCognitiveJob(pandora, 1);
    });

    describe("reportProgress", () => {
        let progress = 10;

        beforeEach(async () => {
            progress++;
        });

        it('should be callable only by owner', async () => {
            assertRevert(workerInstance.reportProgress(progress));
        });

        it.skip("should change worker progress", async () => {
            const progress_one = await workerInstance.jobProgress();

            await workerInstance.reportProgress(progress, {from: workerOwner});

            const progress_two = await workerInstance.jobProgress();

            assert.notEqual(progress_one.toNumber(), progress_two.toNumber(), "Progress was not changed");
        });

        it.skip("should set up provided progress", async () => {
            await workerInstance.reportProgress(progress, {from: workerOwner});

            const jobProgress = await workerInstance.jobProgress();

            assert.equal(jobProgress.toNumber(), progress, "Progress does not match the provided value");
        });

        it.skip("should change active job progress", function (done) {
            let progress_one, timestamp_one, progress_two, timestamp_two, activeJobInstance;

            (async () => {
                activeJobInstance = await CognitiveJob.at(await workerInstance.activeJob());

                progress_one = await workerInstance.jobProgress();
                timestamp_one = await activeJobInstance.responseTimestamps(workerIndex);
            })();

            setTimeout(async () => {
                await workerInstance.reportProgress(++progress, {from: workerOwner});

                progress_two = await workerInstance.jobProgress();
                timestamp_two = await activeJobInstance.responseTimestamps(workerIndex);

                assert.notEqual(progress_one.toNumber(), progress_two.toNumber(), "Progress was not changed");
                assert.notEqual(timestamp_one.toNumber(), timestamp_two.toNumber(), "Job progress timestamp was not changed");
                done();
            }, 1000)
            
        });
    });

    describe("cancelJob", () => {});
    describe("acceptAssignment", () => {});
    describe("processToDataValidation", () => {});
    describe("acceptValidData", () => {});
    describe("processToCognition", () => {});
    describe("provideResults", () => {});

});