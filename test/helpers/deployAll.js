const Pandora = artifacts.require('Pandora');
const Pan = artifacts.require('Pan');
const Reputation = artifacts.require('Reputation');
const CognitiveJobController = artifacts.require('CognitiveJobController');
const WorkerNodeFactory = artifacts.require('WorkerNodeFactory');
const EconomicController = artifacts.require('EconomicController');

module.exports = async (owner) => {
    const pan = await Pan.new({from: owner});
    await pan.initializeMintable(owner, {from: owner});
    await pan.mint(owner, 5000000 * 1000000000000000000, {from: owner});
    const economicController = await EconomicController.new(pan.address, {from: owner});
    await pan.addMinter(economicController.address, {from: owner});        
    const jobController = await CognitiveJobController.new(economicController.address, {from: owner});
    const nodeFactory = await WorkerNodeFactory.new({from: owner});
    const reputation = await Reputation.new({from: owner});
    const pandora = await Pandora.new(jobController.address, economicController.address, nodeFactory.address, reputation.address, {from: owner});
    await nodeFactory.transferOwnership(pandora.address);
    await jobController.transferOwnership(pandora.address);
    await economicController.transferOwnership(pandora.address);
    await reputation.transferOwnership(pandora.address);
    await pandora.initialize();
    await economicController.initialize(pandora.address);

    return {
        pan,
        pandora,
        jobController,
        economicController
    };
};
