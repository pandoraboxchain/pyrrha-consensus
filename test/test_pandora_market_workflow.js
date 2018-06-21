const PandoraMarket = artifacts.require('PandoraMarket');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');

contract('PandoraMarket', accounts => {

    let datasetIpfsAddress = 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj';
    let kernelIpfsAddress = 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ';    
    let numberOfBatches = 2;

    let market;
    let testDataset;
    let testKernel;
    let newDatasetAddress;
    let newKernelAddress;

    before('setup test pandora market', async () => {

        market = await PandoraMarket.deployed();        
        testDataset = await Dataset.new(datasetIpfsAddress, 1, numberOfBatches, 0, "m-a", "d-n");
        testKernel = await Kernel.new(kernelIpfsAddress, 1, 0, 0, "m-a", "d-n");
    });

    it('New Kernel should be added to PandoraMarket', async () => {

        const result = await market.addKernel(testKernel.address, {
            from: accounts[1]
        });
        const logSuccess = result.logs.filter(l => l.event === 'KernelAdded')[0];
        // console.log(logSuccess, 'Kernel added log');

        const newKernelAddress = await market.kernels(0);
        // console.log(newKernelAddress, 'kernelInMarket');

        const kernelInMarketMap = await market.kernelMap(newKernelAddress);
        // console.log(kernelInMarketMap.toNumber(), 'kernelInMarketMap');

        assert.equal(result.logs[0].args.kernel, newKernelAddress,
            'Address of kernel in array should match with created dataset');
        assert.equal(kernelInMarketMap.toNumber(), 1, 'Index of kernel in mapping should match 1');
    });

    it('#kernelsCount should return count of added kernels', async () => {

        const result = await market.addKernel(testKernel.address, {
            from: accounts[1]
        });
        const count = await market.kernelsCount();
        assert.isOk(count > 0, 'kernels count more then 0');
    });

    it('New Dataset should be added to PandoraMarket', async () => {

        const result = await market.addDataset(testDataset.address, {
            from: accounts[1]
        });

        const logSuccess = result.logs.filter(l => l.event === 'DatasetAdded')[0];
        // console.log(logSuccess, 'Dataset added log');

        const newDatasetAddress = await market.datasets(0);
        // console.log(newDatasetAddress, 'datasetInMarket');

        const datasetInMarketMap = await market.datasetMap(newDatasetAddress);
        // console.log(datasetInMarketMap.toNumber(), 'datasetInMarketMap');

        assert.equal(result.logs[0].args.dataset, newDatasetAddress,
            'Address of dataset in array should match with created dataset');
        assert.equal(datasetInMarketMap.toNumber(), 1, 'Index of dataset in mapping should match 1');
    });

    it('#datasetsCount should return count of added datasets', async () => {

        const result = await market.addDataset(testDataset.address, {
            from: accounts[1]
        });
        const count = await market.datasetsCount();
        assert.isOk(count > 0, 'datasets count more then 0');
    });

    it('#removeKernel should delete Kernel and fire event', async () => {

        const newKernelAddress = await market.kernels(0);

        assert.equal(testKernel.address, newKernelAddress,
            'Newly created address should match with newly added kernel in market');

        const kernelInMarketMap = await market.kernelMap(testKernel.address);
        // console.log(kernelInMarketMap.toNumber(), 'kernelInMarketMap');

        const result = await market.removeKernel(testKernel.address, {
            from: accounts[1]
        });
        // console.log(result, 'Deleting kernel log');

        let logSuccess = result.logs.filter(l => l.event === 'KernelRemoved')[0];
        // console.log(logSuccess, 'Kernel remove event');
    });

    it('#removeKernel should not fire an event KernelRemoved on trying to remove not existed kernel', async () => {

        const result = await market.removeKernel('', {
            from: accounts[1]
        });

        const log = result.logs.filter(l => l.event === 'KernelRemoved')[0];
        assert.equal(log, undefined, 'no KernelRemoved events');
    });

    it('Should delete Dataset and fire event', async () => {

        const newDatasetAddress = await market.datasets(0);

        assert.equal(testDataset.address, newDatasetAddress,
            'Newly created address should match with newly added dataset in market');

        const datasetInMarketMap = await market.datasetMap(testDataset.address);
        // console.log(datasetInMarketMap.toNumber(), 'datasetInMarketMap');

        const result = await market.removeDataset(testDataset.address, {
            from: accounts[1]
        });
        // console.log(result, 'Deleting dataset log');

        const logSuccess = result.logs.filter(l => l.event === 'DatasetRemoved')[0];
        // console.log(logSuccess, 'Kernel remove event');
    });

    it('#removeDataset should not fire an event DatasetRemoved on trying to remove not existed dataset', async () => {

        const result = await market.removeDataset('', {
            from: accounts[1]
        });

        const log = result.logs.filter(l => l.event === 'DatasetRemoved')[0];
        assert.equal(log, undefined, 'no DatasetRemoved events');
    });
});
