const PandoraMarket = artifacts.require('PandoraMarket');
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');

contract('PandoraMarket', accounts => {

    let market;
    let testDataset;
    let testKernel;
    let newDatasetAddress;
    let newKernelAddress;

    before('setup', async () => {

        market = await PandoraMarket.deployed();

        let numberOfBatches = 2;
        testDataset = await Dataset.new('', 1, 0, numberOfBatches, 0);

        testKernel = await Kernel.new('', 1, 0, 0);
    });

    it('New Kernel should be added to PandoraMarket', async () => {

        let result = await market.addKernel(testKernel.address, {
            from: accounts[1]
        });
        let logSuccess = result.logs.filter(l => l.event === 'KernelAdded')[0];
        console.log(logSuccess, 'Kernel added log');

        let newKernelAddress = await market.kernels(1); //there is 1 kernel already on 0 position after initial deployment
        console.log(newKernelAddress, 'kernelInMarket');

        let kernelInMarketMap = await market.kernelMap(newKernelAddress);
        console.log(kernelInMarketMap.toNumber(), 'kernelInMarketMap');

        assert.equal(result.logs[0].args.kernel, newKernelAddress,
            'Address of kernel in array should match with created dataset')
        assert.equal(kernelInMarketMap.toNumber(), 2, 'Index of kernel in mapping should match 2');
    });

    it('New Kernel should be added to PandoraMarket', async () => {

        let result = await market.addDataset(testDataset.address, {
            from: accounts[1]
        });

        let logSuccess = result.logs.filter(l => l.event === 'DatasetAdded')[0];
        console.log(logSuccess, 'Dataset added log');

        let newDatasetAddress = await market.datasets(1); //there is 1 dataset already on 0 position after initial deployment
        console.log(newDatasetAddress, 'datasetInMarket');

        let datasetInMarketMap = await market.datasetMap(newDatasetAddress);
        console.log(datasetInMarketMap.toNumber(), 'datasetInMarketMap');

        assert.equal(result.logs[0].args.dataset, newDatasetAddress,
            'Address of dataset in array should match with created dataset');
        assert.equal(datasetInMarketMap.toNumber(), 2, 'Index of dataset in mapping should match 2');
    });

    it('Should delete Kernel and fire event', async () => {

        let newKernelAddress = await market.kernels(1);

        assert.equal(testKernel.address, newKernelAddress,
            'Newly created address should match with newly added kernel in market');

        let kernelInMarketMap = await market.kernelMap(testKernel.address);
        console.log(kernelInMarketMap.toNumber(), 'kernelInMarketMap');

        let result = await market.removeKernel(testKernel.address, {
            from: accounts[1]
        });
        console.log(result, 'Deleting kernel log');

        let logSuccess = result.logs.filter(l => l.event === 'KernelRemoved')[0];
        console.log(logSuccess, 'Kernel remove event');
    });

    it('Should delete Dataset and fire event', async () => {

        let newDatasetAddress = await market.datasets(1);

        assert.equal(testDataset.address, newDatasetAddress,
            'Newly created address should match with newly added dataset in market');

        let datasetInMarketMap = await market.datasetMap(testDataset.address);
        console.log(datasetInMarketMap.toNumber(), 'datasetInMarketMap');

        let result = await market.removeDataset(testDataset.address, {
            from: accounts[1]
        });
        console.log(result, 'Deleting dataset log');

        let logSuccess = result.logs.filter(l => l.event === 'DatasetRemoved')[0];
        console.log(logSuccess, 'Kernel remove event');
    });
});
