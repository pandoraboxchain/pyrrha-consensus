const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

const assertRevert = require('./helpers/assertRevert');
const assertJobState = require('./helpers/assertJobState');
const assertWorkerState = require('./helpers/assertWorkerState');
const assertQueueDepth = require('./helpers/assertQueueDepth');
const assertSuccessResultCode = require('./helpers/assertSuccessResultCode');
const assertFailureResultCode = require('./helpers/assertFailureResultCode');
const getGasPrice = require('./helpers/getGasPrice');

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
    WORKER_STATE_ASSIGNED,
    WORKER_STATE_IDLE,
    WORKER_STATE_COMPUTING,

    BATCHES_COUNT_LIMIT,
    JOBS_COUNT_LIMIT,
    REQUIRED_DEPOSIT,
    QUEUE_PROCEED_LIMIT,

    RESULT_CODE_JOB_CREATED,
    RESULT_CODE_ADD_TO_QUEUE,
    EMPTY,
    BALANCE_INACCURACY
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
        workerInstance1 = await createWorkerNode(pandora, workerOwner1);
        await aliveWorker(workerInstance0, workerOwner0);
    });

    beforeEach(async () =>{
        assertQueueDepth(pandora, 0);
    });

    describe("createCognitiveJob", async () => {
        it('should not create cognitive contract from outside of Pandora', async () => {

            const numberOfBatches = 2;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches, 0, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

            assertRevert(CognitiveJob.new(
                pandora.address, testDataset.address, testKernel.address, [workerInstance0.address], 1, "d-n"));

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it(`should not create job if number of batches more then ${BATCHES_COUNT_LIMIT}`, async () => {
            assertRevert(createCognitiveJob(pandora, 11));
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it("should not create job if dimensions of the input data and neural network input layer is not equal", async () => {
            const batchesCount = 1;
            const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
            const testKernel = await Kernel.new(kernelIpfsAddress, 2, 2, 3, "m-a", "d-n");

            assertRevert(pandora.createCognitiveJob(
                testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)})
            );
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it('Cognitive job should be successfully completed after computation', async () => {

            await createCognitiveJob(pandora, 1);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it(`should not create job if correspond doesn't have founds enough (${web3.fromWei(REQUIRED_DEPOSIT, "ether")} ether) to deposit`, async () => {

            assertRevert(createCognitiveJob(pandora, 1, {value: REQUIRED_DEPOSIT - 1000}));

            await createCognitiveJob(pandora, 1, {value: REQUIRED_DEPOSIT});

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it('should not create job, and put it to queue if # of idle workers < number of batches', async () => {

            await createCognitiveJob(pandora, 1);

            const activeJobCountStart = await pandora.cognitiveJobsCount();
            const result = await createCognitiveJob(pandora, 2);

            const activeJobCountEnd = await pandora.cognitiveJobsCount();

            const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
            const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
            const logEntries = result.logs.length;

            assert.equal(
                activeJobCountEnd.toNumber(),
                activeJobCountStart.toNumber(),
                'Active jobs should not be increased');

            assertFailureResultCode(result, RESULT_CODE_ADD_TO_QUEUE);

            assert.equal(logEntries, 1, 'Should be fired only 1 event');
            assert.isOk(logFailure, 'Should be fired failed event');
            assert.isNotOk(logSuccess, 'Should not be fired successful creation event');


            // Erase queue
            await aliveWorker(workerInstance1, workerOwner1);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);

            assertQueueDepth(pandora, 0);

            assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_ASSIGNED, 1);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            await finishActiveJob(pandora, workerInstance1, workerOwner1);

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        });

        it("should create job if it's ok", async () => {

            const active_job_count_start = await pandora.cognitiveJobsCount();

            const result = await createCognitiveJob(pandora, 1);

            const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
            const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
            const logEntries = result.logs.length;

            const activeJob = await workerInstance0.activeJob.call();

            const active_job_count_end = await pandora.cognitiveJobsCount();

            assert.equal(
                active_job_count_end.toNumber(),
                active_job_count_start.toNumber() + 1,
                'Active jobs count should be increased');

            assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);

            assert.notEqual(activeJob, EMPTY, 'Should set activeJob to worker node');

            assertSuccessResultCode(result, RESULT_CODE_JOB_CREATED);

            assert.equal(logEntries, 2, 'Should be fired only 2 events');
            assert.isNotOk(logFailure, 'Should not be fired failed event');
            assert.isOk(logSuccess, 'Should be fired successful creation event');

            await finishActiveJob(pandora, workerInstance0, workerOwner0);

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        });

        it("should not hold payment from customer if job not putted into the queue", async () => {
            const depositBefore = await pandora.deposits.call(customer);
            const balanceBefore = await web3.eth.getBalance(customer);

            const {receipt: { gasUsed }} = await createCognitiveJob(pandora, 1, {from: customer});

            const gasPrice = await getGasPrice();

            await assertQueueDepth(pandora, 0);

            const depositAfter = await pandora.deposits.call(customer);
            const balanceAfter = await web3.eth.getBalance(customer);

            const gasFee = gasPrice.mul(gasUsed).toNumber();

            const balanceDelta = balanceBefore.toNumber() - balanceAfter.toNumber() - gasFee;
            const depositDelta = web3.fromWei(depositAfter.toNumber() - depositBefore.toNumber(), "ether");

            assert.isOk(balanceDelta < BALANCE_INACCURACY, `Balance inaccuracy should less than BALANCE_INACCURACY (${BALANCE_INACCURACY})`);
            assert.equal(depositDelta, 0, 'Deposit should not be changed');

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            await finishActiveJob(pandora, workerInstance1, workerOwner1);


            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        });

        it("should hold payment from customer if job was putted into the queue", async () => {
            await createCognitiveJob(pandora, 1);

            const balanceBefore = await web3.eth.getBalance(customer);
            const depositBefore = await pandora.deposits.call(customer);

            const {receipt: {gasUsed}} = await createCognitiveJob(pandora, 2, {from: customer});

            const gasPrice = await getGasPrice();

            const depositAfter = await pandora.deposits.call(customer);
            const balanceAfter = await web3.eth.getBalance(customer);

            const gasFee = gasPrice.mul(gasUsed).toNumber();

            const balanceDelta = web3.fromWei(balanceBefore.toNumber() - balanceAfter.toNumber() - gasFee, "ether");
            const depositDelta = web3.fromWei(depositAfter.toNumber() - depositBefore.toNumber(), "ether");

            assert.notEqual(depositBefore.toNumber(), depositAfter.toNumber(), 'Deposit should be changed');
            assert.equal(balanceDelta, balanceDelta, `Balance changes (${balanceDelta}) should be tha same as deposit changes (${depositDelta})`);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            await finishActiveJob(pandora, workerInstance1, workerOwner1);

            await assertQueueDepth(pandora, 0);

            await finishActiveJob(pandora, workerInstance0, workerOwner0);
            await finishActiveJob(pandora, workerInstance1, workerOwner1);

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        });
    });

    describe("isActiveJob", async () => {
        it('should return if job not exist', async () => {
            const isActiveJob = await pandora.isActiveJob('');
            assert.equal(isActiveJob, false, 'Job is not in the jobAddresses list');
        });
    });
});