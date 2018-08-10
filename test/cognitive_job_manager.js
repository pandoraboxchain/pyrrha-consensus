const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJobController = artifacts.require('CognitiveJobController');

const assertRevert = require('./helpers/assertRevert');
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
    acceptAssignment,
    processToDataValidation,
    acceptValidData,
    processToCognition,
    provideResults,
    createCognitiveJob,
    datasetIpfsAddress,
    kernelIpfsAddress
} = require("./helpers/cognitive_job_manager");

const {
    WORKER_STATE_ASSIGNED,
    WORKER_STATE_IDLE,

    BATCHES_COUNT_LIMIT,
    REQUIRED_DEPOSIT,
    QUEUE_PROCEED_LIMIT,

    RESULT_CODE_JOB_CREATED,
    RESULT_CODE_ADD_TO_QUEUE,
    EMPTY,
    BALANCE_INACCURACY
} = require("./constants");

contract('CognitiveJobManager', accounts => {

    let pandora;
    let jobController;

    let workerInstance0;
    let workerInstance1;
    let workerInstance2;

    const workerOwner0 = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const customer = accounts[5];

    before('setup test cognitive job manager', async () => {
        pandora = await Pandora.deployed();
        jobController = await CognitiveJobController.deployed();

        workerInstance0 = await createWorkerNode(pandora, workerOwner0);
        workerInstance1 = await createWorkerNode(pandora, workerOwner1);
        await aliveWorker(workerInstance0, workerOwner0);
    });

    beforeEach(async () =>{
        assertQueueDepth(pandora, 0);
    });

    describe("createCognitiveJob", async () => {

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

            let receipt = await createCognitiveJob(pandora, 1);

            // let result = await jobController.getCognitiveJobDetails.call(args.jobId);
            // console.log(result);
            //
            // let resultS = await jobController.getCognitiveJobResults.call(args.jobId, 0);
            // console.log(resultS);

            await acceptAssignment(pandora, workerInstance0, workerOwner0);
            await processToDataValidation(pandora, workerInstance0, workerOwner0);
            await acceptValidData(pandora, workerInstance0, workerOwner0);
            await processToCognition(pandora, workerInstance0, workerOwner0);
            await provideResults(pandora, workerInstance0, workerOwner0);

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        });

        it(`should not create job if customer doesn't have founds enough (${web3.fromWei(REQUIRED_DEPOSIT, "ether")} ether) to deposit`, async () => {

            assertRevert(createCognitiveJob(pandora, 1, {value: REQUIRED_DEPOSIT - 1000}));
        });

        it('should not create job, and put it to queue if # of idle workers < number of batches', async () => {

            await createCognitiveJob(pandora, 1);

            const activeJobCountStart = await jobController.activeJobsCount();

            const result = await createCognitiveJob(pandora, 2);

            const activeJobCountEnd = await jobController.activeJobsCount();

            const logCreated = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
            const logQueued = result.logs.filter(l => l.event === 'CognitiveJobQueued')[0];
            const logEntries = result.logs.length;

            assert.equal(
                activeJobCountEnd.toNumber(),
                activeJobCountStart.toNumber(),
                'Active jobs should not be increased');

            // assertFailureResultCode(result, RESULT_CODE_ADD_TO_QUEUE);

            assert.equal(logEntries, 1, 'Should be fired only 1 event');
            assert.isOk(logQueued, 'Should be fired failed event');
            assert.isNotOk(logCreated, 'Should not be fired successful creation event');

            // Erase queue
            await aliveWorker(workerInstance1, workerOwner1);

            await acceptAssignment(pandora, workerInstance0, workerOwner0);
            await processToDataValidation(pandora, workerInstance0, workerOwner0);
            await acceptValidData(pandora, workerInstance0, workerOwner0);
            await processToCognition(pandora, workerInstance0, workerOwner0);
            await provideResults(pandora, workerInstance0, workerOwner0);

            await pandora.checkJobQueue();

            assertQueueDepth(pandora, 0);

            assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
            assertWorkerState(workerInstance1, WORKER_STATE_ASSIGNED, 1);

            await acceptAssignment(pandora, workerInstance0, workerOwner0);
            await acceptAssignment(pandora, workerInstance1, workerOwner1);
            await processToDataValidation(pandora, workerInstance0, workerOwner0);
            await processToDataValidation(pandora, workerInstance1, workerOwner1);
            await acceptValidData(pandora, workerInstance0, workerOwner0);
            await acceptValidData(pandora, workerInstance1, workerOwner1);
            await processToCognition(pandora, workerInstance0, workerOwner0);
            await processToCognition(pandora, workerInstance1, workerOwner1);
            await provideResults(pandora, workerInstance0, workerOwner0);
            await provideResults(pandora, workerInstance1, workerOwner1);

        });

        // it("should create job if it's ok", async () => {
        //
        //     const active_job_count_start = await pandora.cognitiveJobsCount();
        //
        //     const result = await createCognitiveJob(pandora, 1);
        //
        //     const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
        //     const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
        //     const logEntries = result.logs.length;
        //
        //     const activeJob = await workerInstance0.activeJob.call();
        //
        //     const active_job_count_end = await pandora.cognitiveJobsCount();
        //
        //     assert.equal(
        //         active_job_count_end.toNumber(),
        //         active_job_count_start.toNumber() + 1,
        //         'Active jobs count should be increased');
        //
        //     assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
        //
        //     assert.notEqual(activeJob, EMPTY, 'Should set activeJob to worker node');
        //
        //     assertSuccessResultCode(result, RESULT_CODE_JOB_CREATED);
        //
        //     assert.equal(logEntries, 2, 'Should be fired only 2 events');
        //     assert.isNotOk(logFailure, 'Should not be fired failed event');
        //     assert.isOk(logSuccess, 'Should be fired successful creation event');
        //
        //     await finishActiveJob(pandora, workerInstance0, workerOwner0);
        //
        //     assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        //     assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        // });
        //
        // it("should not hold payment from customer if job not putted into the queue", async () => {
        //     const depositBefore = await pandora.deposits.call(customer);
        //     const balanceBefore = await web3.eth.getBalance(customer);
        //
        //     const {receipt: { gasUsed }} = await createCognitiveJob(pandora, 1, {from: customer});
        //
        //     const gasPrice = await getGasPrice();
        //
        //     await assertQueueDepth(pandora, 0);
        //
        //     const depositAfter = await pandora.deposits.call(customer);
        //     const balanceAfter = await web3.eth.getBalance(customer);
        //
        //     const gasFee = gasPrice.mul(gasUsed).toNumber();
        //
        //     const balanceDelta = balanceBefore.toNumber() - balanceAfter.toNumber() - gasFee;
        //     const depositDelta = web3.fromWei(depositAfter.toNumber() - depositBefore.toNumber(), "ether");
        //
        //     assert.isOk(balanceDelta < BALANCE_INACCURACY, `Balance inaccuracy should less than BALANCE_INACCURACY (${BALANCE_INACCURACY})`);
        //     assert.equal(depositDelta, 0, 'Deposit should not be changed');
        //
        //     await finishActiveJob(pandora, workerInstance0, workerOwner0);
        //     await finishActiveJob(pandora, workerInstance1, workerOwner1);
        //
        //
        //     assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        //     assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        // });
        //
        // it("should hold payment from customer if job was putted into the queue", async () => {
        //     await createCognitiveJob(pandora, 1);
        //
        //     const balanceBefore = await web3.eth.getBalance(customer);
        //     const depositBefore = await pandora.deposits.call(customer);
        //
        //     const {receipt: {gasUsed}} = await createCognitiveJob(pandora, 2, {from: customer});
        //
        //     const gasPrice = await getGasPrice();
        //
        //     const depositAfter = await pandora.deposits.call(customer);
        //     const balanceAfter = await web3.eth.getBalance(customer);
        //
        //     const gasFee = gasPrice.mul(gasUsed).toNumber();
        //
        //     const balanceDelta = web3.fromWei(balanceBefore.toNumber() - balanceAfter.toNumber() - gasFee, "ether");
        //     const depositDelta = web3.fromWei(depositAfter.toNumber() - depositBefore.toNumber(), "ether");
        //
        //     assert.notEqual(depositBefore.toNumber(), depositAfter.toNumber(), 'Deposit should be changed');
        //     assert.equal(balanceDelta, balanceDelta, `Balance changes (${balanceDelta}) should be tha same as deposit changes (${depositDelta})`);
        //
        //     await finishActiveJob(pandora, workerInstance0, workerOwner0);
        //     await finishActiveJob(pandora, workerInstance1, workerOwner1);
        //
        //     await assertQueueDepth(pandora, 0);
        //
        //     await finishActiveJob(pandora, workerInstance0, workerOwner0);
        //     await finishActiveJob(pandora, workerInstance1, workerOwner1);
        //
        //     assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
        //     assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        // });
    });

    describe("checkJobQueue", () => {
        it.skip(`should proceed job only if there is at least one idle worker`, async () => {});
        it.skip(`should proceed job only if butches count at least equal to number of idle workers`, async () => {});
        it(`should init cognitive job from queue`, async () => {
            let result = await createCognitiveJob(pandora, 2);

            // assertSuccessResultCode(result, RESULT_CODE_JOB_CREATED);

            result = await createCognitiveJob(pandora, 2);

            // assertFailureResultCode(result, RESULT_CODE_ADD_TO_QUEUE);

            assertQueueDepth(pandora, 1);

            await acceptAssignment(pandora, workerInstance0, workerOwner0);
            await acceptAssignment(pandora, workerInstance1, workerOwner1);
            await processToDataValidation(pandora, workerInstance0, workerOwner0);
            await processToDataValidation(pandora, workerInstance1, workerOwner1);
            await acceptValidData(pandora, workerInstance0, workerOwner0);
            await acceptValidData(pandora, workerInstance1, workerOwner1);
            await processToCognition(pandora, workerInstance0, workerOwner0);
            await processToCognition(pandora, workerInstance1, workerOwner1);
            await provideResults(pandora, workerInstance0, workerOwner0);
            await provideResults(pandora, workerInstance1, workerOwner1);

            await pandora.checkJobQueue();

            assertQueueDepth(pandora, 0);

            // assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
            // assertWorkerState(workerInstance1, WORKER_STATE_ASSIGNED, 1);

            await acceptAssignment(pandora, workerInstance0, workerOwner0);
            await acceptAssignment(pandora, workerInstance1, workerOwner1);
            await processToDataValidation(pandora, workerInstance0, workerOwner0);
            await processToDataValidation(pandora, workerInstance1, workerOwner1);
            await acceptValidData(pandora, workerInstance0, workerOwner0);
            await acceptValidData(pandora, workerInstance1, workerOwner1);
            await processToCognition(pandora, workerInstance0, workerOwner0);
            await processToCognition(pandora, workerInstance1, workerOwner1);
            await provideResults(pandora, workerInstance0, workerOwner0);
            await provideResults(pandora, workerInstance1, workerOwner1);

            // assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
            // assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
        });
    //     it("should debit customer max deposit value for transaction fee", async () => {
    //
    //         let result = await createCognitiveJob(pandora, 2);
    //
    //         assertSuccessResultCode(result, RESULT_CODE_JOB_CREATED);
    //
    //         const logSuccess = result.logs.filter(l => l.event === 'CognitiveJobCreated')[0];
    //         const logFailure = result.logs.filter(l => l.event === 'CognitiveJobCreateFailed')[0];
    //
    //         assert.isOk(logSuccess, 'should not be fired successful creation event');
    //         assert.isNotOk(logFailure, 'should be fired failed event');
    //
    //         assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
    //         assertWorkerState(workerInstance1, WORKER_STATE_ASSIGNED, 1);
    //
    //         result = await createCognitiveJob(pandora, 2, {from: customer});
    //
    //         const activeJobBefore = await workerInstance0.activeJob.call();
    //         const balanceBefore = await web3.eth.getBalance(customer);
    //
    //         assertFailureResultCode(result, RESULT_CODE_ADD_TO_QUEUE);
    //
    //         const depositBefore = await pandora.deposits.call(customer);
    //         assert.isOk(depositBefore >= REQUIRED_DEPOSIT, "Deposit should be setted");
    //
    //         await finishActiveJob(pandora, workerInstance0, workerOwner0);
    //         await finishActiveJob(pandora, workerInstance1, workerOwner1);
    //
    //         const activeJobAfter = await workerInstance0.activeJob.call();
    //         assert.notEqual(activeJobBefore, activeJobAfter, 'Active job should be changed');
    //
    //         const depositAfter = await pandora.deposits.call(customer);
    //         assert.equal(depositAfter, 0, "Deposit should be erased");
    //
    //         const balanceAfter = await web3.eth.getBalance(customer);
    //
    //         const balanceDelta = balanceAfter - balanceBefore;
    //         assert.isOk(balanceDelta >= 0, "Balance could be increased");
    //
    //         assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED, 0);
    //         assertWorkerState(workerInstance1, WORKER_STATE_ASSIGNED, 1);
    //
    //         await finishActiveJob(pandora, workerInstance0, workerOwner0);
    //         await finishActiveJob(pandora, workerInstance1, workerOwner1);
    //
    //         assertWorkerState(workerInstance0, WORKER_STATE_IDLE, 0);
    //         assertWorkerState(workerInstance1, WORKER_STATE_IDLE, 1);
    //
    //     });
    });
    //
    // describe("isActiveJob", async () => {
    //     it('should return if job not exist', async () => {
    //         const isActiveJob = await pandora.isActiveJob('');
    //         assert.equal(isActiveJob, false, 'Job is not in the jobAddresses list');
    //     });
    // });
});