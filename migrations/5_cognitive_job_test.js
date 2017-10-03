var StateMachineLib = artifacts.require("StateMachineLib");
var Pandora = artifacts.require("Pandora");
var Kernel = artifacts.require("Kernel");
var Dataset = artifacts.require("Dataset");
var WorkerNode = artifacts.require("WorkerNode");
var CognitiveJob = artifacts.require("CognitiveJob");

module.exports = function(deployer) {
  deployer.link(StateMachineLib, CognitiveJob);
  deployer.deploy(CognitiveJob, Pandora.address, Kernel.address, Dataset.address, [ WorkerNode.address ], 454, { gas: 6000000 });
};
