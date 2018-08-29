const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
// const CognitiveJob = artifacts.require('CognitiveJob');

const assertQueueDepth = require('./helpers/assertQueueDepth');

const {
    createWorkerNode
} = require("./helpers/worker_node_manager");

const {
    aliveWorker
} = require("./helpers/worker_node");

const {
    finishActiveJob,
    createCognitiveJob,
} = require("./helpers/cognitive_job_manager");

contract('CognitiveJobManager', accounts => {

    let pandora;
    const workers = [];
    const workersCount = 10;
    const owner = accounts[6];

    before('setup test cognitive job manager', async () => {

        pandora = await Pandora.deployed();

        assert.equal(await pandora.workerNodesCount(), 0, "It should not be any workers at the beginning");

        for (let i = 0; i < workersCount; i++) {
            workers.push(await createWorkerNode(pandora, owner));
        }
    });
    describe("checkJobQueue", () => {
        it.skip("should get from queue 1 job with 10 batches", async () => {
            assert.equal(await pandora.workerNodesCount(), workersCount, `It should ${workersCount} workers be created for test`);

            await aliveWorker(workers[0], owner);

            await createCognitiveJob(pandora, 1);

            const batchesCount = 10;
            const worksCount = 1;

            for (let i = 0; i < worksCount; i++) {
                await createCognitiveJob(pandora, batchesCount);
            }

            assertQueueDepth(pandora, worksCount);

            for (let i = 1; i < workersCount; i++) {
                await aliveWorker(workers[i], owner);
            }

            await  finishActiveJob(pandora, workers[0], owner);

            assertQueueDepth(pandora, 0);
        });
    });
});