'use strict';

const path = require('path');
const Pan = artifacts.require('Pan');
const Pandora = artifacts.require('Pandora');
const WorkerNode = artifacts.require('WorkerNode');
const WorkerNodeFactory = artifacts.require('WorkerNodeFactory');
const CognitiveJobController = artifacts.require('CognitiveJobController');
const EconomicController = artifacts.require('EconomicController');
const StateMachineLib = artifacts.require('StateMachineLib');
const JobQueueLib = artifacts.require('JobQueueLib');
const Reputation = artifacts.require('Reputation');
const {
    saveAddressToFile
} = require('./utils');

module.exports = (deployer, network, accounts) => {
    let pan, pandora, wnf, cognitiveJobController, economicController, reputation;

    return deployer
        .then(_ => deployer.deploy(JobQueueLib))
        .then(_ => deployer.deploy(StateMachineLib))
        .then(_ => deployer.link(StateMachineLib, WorkerNode))
        .then(_ => deployer.deploy(Reputation))
        .then(_ => Reputation.deployed())
        .then(instance => {
            reputation = instance
            return deployer.deploy(Pan);
        })
        .then(instance => {
            pan = instance;
            return pan.initializeMintable(accounts[0]);// add accounts[0] as minter role
        })
        .then(_ => pan.mint(accounts[0], 5000000 * 1000000000000000000, {from: accounts[0]}))// initial tokens emission
        .then(_ => deployer.deploy(EconomicController, pan.address))
        .then(_ => EconomicController.deployed())
        .then(instance => {
            economicController = instance;
            return pan.addMinter(economicController.address, {from: accounts[0]});// for "mining" purposes
        })
        .then(_ => deployer.deploy(CognitiveJobController, economicController.address))
        .then(_ => CognitiveJobController.deployed())
        .then(instance => {
            cognitiveJobController = instance;
            return deployer.deploy(WorkerNodeFactory);
        })
        .then(_ => WorkerNodeFactory.deployed())
        .then(instance => {
            wnf = instance;
            deployer.link(JobQueueLib, Pandora);            
            return deployer.deploy(Pandora, cognitiveJobController.address, economicController.address, wnf.address, reputation.address);
        })
        .then(_ => Pandora.deployed())
        .then(instance => {
            pandora = instance;
            return wnf.transferOwnership(pandora.address);
        })      
        .then(_ => cognitiveJobController.transferOwnership(pandora.address))
        .then(_ => economicController.transferOwnership(pandora.address))
        .then(_ => reputation.transferOwnership(pandora.address))
        .then(_ => pandora.initialize())
        .then(_ => economicController.initialize(pandora.address))
        .then(_ => saveAddressToFile(deployer.basePath, 'Pandora.json', JSON.stringify(pandora.address)))
        .catch(console.error);
};
