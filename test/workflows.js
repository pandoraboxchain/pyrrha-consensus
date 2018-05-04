const Pandora = artifacts.require('PandoraHooks'); // *** NB: version with hooks (for testing) instead of normal contract)
const Dataset = artifacts.require('Dataset');
const Kernel = artifacts.require('Kernel');
const IWorkerNode = artifacts.require('IWorkerNode');
const CognitiveJob = artifacts.require('CognitiveJob');

contract('Pandora', accounts => {

    it.skip('shouldn\'t create cognitive contract from outside of Pandora', async () => {
        
        const pandora = await Pandora.deployed();
        const workerNode = await pandora.workerNodes(0);
        const receipt = await deployer.deploy(CognitiveJob, pandora.address, Kernel.address, Dataset.address, [workerNode.address]);
        
        console.log(receipt);
    });
});
