const Pandora = artifacts.require('Pandora');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const WorkerNode = artifacts.require('WorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');
const assertRevert = require('./helpers/assertRevert');

contract('WorkerNode', accounts => {

    const datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    const kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';

    let pandora;

    let workerNode;

    let workerIndex = 0;

    let workerOwner = accounts[0];

    let workerInstance;

    before('setup', async () => {

        pandora = await Pandora.deployed();

        await pandora.whitelistWorkerOwner(workerOwner);
        workerNode = await pandora.createWorkerNode({
            from: workerOwner
        });

        const idleWorkerAddress = await pandora.workerNodes.call(workerIndex);

        workerInstance = await WorkerNode.at(idleWorkerAddress);
        await workerInstance.alive({
            from: workerOwner
        });

        const batchesCount = 1;
        const testDataset = await Dataset.new(datasetIpfsAddress, 1, batchesCount, 10, "m-a", "d-n");
        const testKernel = await Kernel.new(kernelIpfsAddress, 1, 2, 3, "m-a", "d-n");

        await pandora.createCognitiveJob(testKernel.address, testDataset.address, 100, "d-n", {value: web3.toWei(0.5)});
    });

    describe("reportProgress", () => {
        let progress = 10;

        beforeEach(async () => {
            progress++;
        });

        it('should be callable only by owner', async () => {
            assertRevert(workerInstance.reportProgress(progress, {from: accounts[1]}));

            await workerInstance.reportProgress(progress, {from: workerOwner});
        });

        it("should change worker progress", async () => {
            const progress_one = await workerInstance.jobProgress.call();

            await workerInstance.reportProgress(progress, {from: workerOwner});

            const progress_two = await workerInstance.jobProgress.call();

            assert.notEqual(progress_one.toNumber(), progress_two.toNumber(), "Progress was not changed");
        });

        it("should set up provided progress", async () => {
            await workerInstance.reportProgress(progress, {from: workerOwner});

            const jobProgress = await workerInstance.jobProgress.call();

            assert.equal(jobProgress.toNumber(), progress, "Progress does not match the provided value");
        });

        it("should change active job progress", async () => {
            const activeJob = await workerInstance.activeJob.call();
            const activeJobInstance = CognitiveJob.at(activeJob);

            const progress_one = await workerInstance.jobProgress.call();
            const timestamp_one = await activeJobInstance.responseTimestamps.call(workerIndex);

            setTimeout(async () => {
                await workerInstance.reportProgress(++progress, {from: workerOwner});

                const progress_two = await workerInstance.jobProgress.call();
                const timestamp_two = await activeJobInstance.responseTimestamps.call(workerIndex);

                assert.notEqual(progress_one.toNumber(), progress_two.toNumber(), "Progress was not changed");
                assert.notEqual(timestamp_one.toNumber(), timestamp_two.toNumber(), "Job progress timestamp was not changed");
            }, 5000)
        });
    });

    describe("cancelJob", () => {});
    describe("acceptAssignment", () => {});
    describe("processToDataValidation", () => {});
    describe("acceptValidData", () => {});
    describe("processToCognition", () => {});
    describe("provideResults", () => {});

});