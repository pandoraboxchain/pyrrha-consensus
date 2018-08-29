const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
// const CognitiveJob = artifacts.require('CognitiveJob');

const {
    assertWorkerState,
    assertRevert,
    assertQueueDepth,
    expectThrow
} = require('./helpers');

const {
    IS_NOT_CONTRACT
} = require("./constants");

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

const {
    WORKER_STATE_ASSIGNED,
    WORKER_STATE_IDLE,
} = require("./constants");

contract.skip('WorkerNodeManager', accounts => {

    let pandora;

    let workerInstance0;
    let workerInstance1;
    let workerInstance2;

    const workerOwner0 = accounts[2];
    const workerOwner1 = accounts[3];
    const workerOwner2 = accounts[4];
    const customer = accounts[5];

    before('setup test worker node manager', async () => {
        pandora = await Pandora.deployed();
    });

    describe("whitelistWorkerOwner", () => {
        it("should add address to the whitelist", async () => {
            const valueBefore = await pandora.workerNodeOwners(customer);
            assert.equal(valueBefore, false, "Address should not be at whitelist by default");

            await pandora.whitelistWorkerOwner(customer);

            const valueAfter = await pandora.workerNodeOwners(customer);
            assert.equal(valueAfter, true, "Address should be added into the whitelist");

        })
    });

    describe("blacklistWorkerOwner", () => {
        it("should removes address from the whitelist", async () => {
            await pandora.whitelistWorkerOwner(customer);

            const valueBefore = await pandora.workerNodeOwners(customer);
            assert.equal(valueBefore, true, "Address should be added into the whitelist");

            await pandora.blacklistWorkerOwner(customer);

            const valueAfter = await pandora.workerNodeOwners(customer);
            assert.equal(valueAfter, false, "Address should be removed from the whitelist");
        });
    });

    describe("createWorkerNode", () => {
        it("should create worker node", async () => {
            await pandora.whitelistWorkerOwner(workerOwner0);
            const nodeId = await pandora.workerNodesCount();

            const result =  await pandora.createWorkerNode({from: workerOwner0});
            const { event } = result.logs.filter(l => l.event === 'WorkerNodeCreated')[0];
        
            assert.equal(event, "WorkerNodeCreated");
           
            const idleWorkerAddress = await pandora.workerNodes.call(nodeId.toNumber());
        
            workerInstance0 = await WorkerNode.at(idleWorkerAddress);
            await aliveWorker(workerInstance0, workerOwner0);
        });
    });

    describe("penaltizeWorkerNode", () => {
        it.skip("should be covered with tests", async () => {});
    });

    describe("destroyWorkerNode", () => {
        it.skip("should be called only by workers owner", async () => {
            assertRevert(pandora.destroyWorkerNode(workerInstance0.address));
        })
        it.skip("should be called only for registered worker", async () => {
            assertRevert(pandora.destroyWorkerNode(customer));
        })
        it.skip("should be called only for IDLE worker", async () => {
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE);
            
            await createCognitiveJob(pandora, 1);

            assertWorkerState(workerInstance0, WORKER_STATE_ASSIGNED);

            assertRevert(pandora.destroyWorkerNode(workerInstance0.address, {from: workerOwner0}));

            await finishActiveJob(pandora, workerInstance0, workerOwner0);

            assertWorkerState(workerInstance0, WORKER_STATE_IDLE);
            
            assertQueueDepth(pandora, 0);
        });

        it.skip("should destroy worker node", async() => {
            workerInstance1 = await createWorkerNode(pandora, workerOwner1);
            await aliveWorker(workerInstance1, workerOwner1);
            
            assertWorkerState(workerInstance0, WORKER_STATE_IDLE);

            const removedIndexBefore = await pandora.workerAddresses(workerInstance0.address);

            assert.notEqual(removedIndexBefore, 0, "Worker should be in the map before removing");

            const workersCount = await pandora.workerNodesCount();
            const removedNodeBefore = await pandora.workerNodes(removedIndexBefore - 1);
            const movedNodeBefore = await pandora.workerNodes(workersCount - 1);
            
            assert.equal(removedNodeBefore, workerInstance0.address, "Worker should be in the list before removing");
            
            await pandora.destroyWorkerNode(workerInstance0.address, {from: workerOwner0});
            
            const removedIndexAfter = await pandora.workerAddresses(workerInstance0.address);

            const movedNodeAfter = await pandora.workerNodes(removedIndexBefore - 1);
            
            assert.equal(removedIndexAfter.toNumber(), 0, "Worker should be removed from the map");
            assert.equal(movedNodeAfter, movedNodeBefore, "Removed worker should be replaced by the last one");

            expectThrow(workerInstance0.jobProgress(), IS_NOT_CONTRACT);
        });
    });
});