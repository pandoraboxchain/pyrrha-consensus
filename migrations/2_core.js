'use strict';

const path = require('path');
const Pandora = artifacts.require('Pandora');
const WorkerNode = artifacts.require('WorkerNode');
const WorkerNodeFactory = artifacts.require('WorkerNodeFactory');
const CognitiveJobController = artifacts.require('CognitiveJobController');
const StateMachineLib = artifacts.require('StateMachineLib');
const JobQueueLib = artifacts.require('JobQueueLib');
const Reputation = artifacts.require('Reputation')
const {
    saveAddressToFile
} = require('./utils');

module.exports = (deployer, network, accounts) => {
    let pandora, wnf, cognitiveJobController, reputation;

    return deployer
        .then(_ => deployer.deploy(JobQueueLib))
        .then(_ => deployer.deploy(StateMachineLib))
        .then(_ => deployer.link(StateMachineLib, WorkerNode))
        .then(_ => {
            return deployer.deploy(Reputation)
        })
        .then(_ => Reputation.deployed())
        .then(instance => {
            reputation = instance
            return deployer.deploy(CognitiveJobController)
        })
        .then(_ => CognitiveJobController.deployed())
        .then(instance => {
            cognitiveJobController = instance
            return deployer.deploy(WorkerNodeFactory)
        })
        .then(_ => WorkerNodeFactory.deployed())
        .then(instance => {
            wnf = instance
            deployer.link(JobQueueLib, Pandora)
            return deployer.deploy(Pandora, cognitiveJobController.address, wnf.address, reputation.address)
        })
        .then(_ => Pandora.deployed())
        .then(instance => {
            pandora = instance
            return saveAddressToFile(deployer.basePath, 'Pandora.json', JSON.stringify(pandora.address));
        })
        .then(_ => pandora.whitelistWorkerOwner(accounts[0]))
        .then(_ => wnf.transferOwnership(pandora.address))
        .then(_ => cognitiveJobController.transferOwnership(pandora.address))
        .then(_ => reputation.transferOwnership(pandora.address))
        .then(_ => pandora.initialize())
        .catch(console.error);
};
