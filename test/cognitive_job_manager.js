const assertRevert = require('./helpers/assertRevert');
const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

const {
    createWorkerNode
} = require("./helpers/worker_node_manager");

const {
    aliveWorker
} = require("./helpers/worker_node");

const {
    finishActiveJob,
    createCognitiveJob,
    datasetIpfsAddress,
    kernelIpfsAddress
} = require("./helpers/cognitive_job_manager");

const {
    WORKER_STATE_COMPUTING,
    WORKER_STATES,

    JOB_STATE_COMPLETED,
    JOB_STATES,

    BATCHES_COUNT_LIMIT,
    JOBS_COUNT_LIMIT,
    REQUIRED_DEPOSIT,
    QUEUE_PROCEED_LIMIT,

    RESULT_CODE_JOB_CREATED,
    RESULT_CODE_ADD_TO_QUEUE,
    EMPTY
} = require("./constants");

contract('CognitiveJobManager', accounts => {

    let pandora;

    let workerInstance0;
    let workerInstance1;
    let workerInstance2;

    const workerOwner0 = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const customer = accounts[5];

    before('setup test cognitive job manager', async () => {

        pandora = await Pandora.deployed();

        workerInstance0 = await createWorkerNode(pandora, workerOwner0);
        await aliveWorker(workerInstance0, workerOwner0);
    });

    describe("createCognitiveJob", async () => {
        it('should not create cognitive contract from outside of Pandora', async () => {

            const numberOfBatches = 2;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches, 0, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

            assertRevert(CognitiveJob.new(
                pandora.address, testDataset.address, testKernel.address, [workerInstance0.address], 1, "d-n"));
        });

        it(`should not create job if number of batches more then ${BATCHES_COUNT_LIMIT}`, async () => {
            assertRevert(createCognitiveJob(pandora, 11));
        });

        it("should not create job if dimensions of the input data and neural network input layer is not equal", async () => {
            const batchesCount = 1;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 2, 2, 3, "m-a", "d-n");

            assertRevert(pandora.createCognitiveJob(
                testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)})
            );
        });

        it('Should not create job, and put it to queue if # of idle workers < number of batches', async () => {

            const result = await createCognitiveJob(pandora, 2);

            const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
            const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
            const logEntries = result.logs.length;

            const activeJobsCount = await pandora.cognitiveJobsCount();

            assert.equal(activeJobsCount.toNumber(), 0, 'activeJobsCount = 0');

            assert.equal(
                result.logs[0].args.resultCode,
                RESULT_CODE_ADD_TO_QUEUE,
                'Result code in event should match RESULT_CODE_ADD_TO_QUEUE'
            );

            assert.equal(logEntries, 1, 'should be fired only 1 event');
            assert.isOk(logFailure, 'should be fired failed event');
            assert.isNotOk(logSuccess, 'should not be fired successful creation event');
        });

        it('Congitive job should be successfully completed after computation', async () => {

            await createCognitiveJob(pandora, 1);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
        });

        it('Should create job if number of idle workers >= number of batches in dataset and complete it', async () => {


            //lets create 30 jobs and finish them
            for (let i = 0; i < 3; i++) {

                const result = await createCognitiveJob(pandora, 1);

                const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
                const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
                let logEntries = result.logs.length;

                let activeJob = await workerInstance0.activeJob.call();
                let workerState = await workerInstance0.currentState.call();
                const activeJobsCount = await pandora.cognitiveJobsCount();

                assert.equal(activeJobsCount.toNumber(), i + 2, 'activeJobsCount should increase');
                assert.equal(workerState.toNumber(), 3, `worker state should be "assigned"`);
                assert.notEqual(activeJob, '0x0000000000000000000000000000000000000000', 'should set activeJob to worker node');
                assert.equal(result.logs[1].args.resultCode, RESULT_CODE_JOB_CREATED, 'result code in event should match RESULT_CODE_JOB_CREATED');
                assert.equal(logEntries, 2, 'should be fired only 2 events');
                assert.isNotOk(logFailure, 'should not be fired failed event');
                assert.isOk(logSuccess, 'should be fired successful creation event');

                await finishActiveJob(pandora, workerInstance0, workerOwner0);
            }
        });
    });

    describe("isActiveJob", async () => {
        it('should return if job not exist', async () => {
            const isActiveJob = await pandora.isActiveJob('');
            assert.equal(isActiveJob, false, 'Job is not in the jobAddresses list');
        });
    });

});