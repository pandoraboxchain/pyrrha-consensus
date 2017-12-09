var DatasetContract = artifacts.require("Dataset");
var KernelContract = artifacts.require("Kernel");
var WorkerNode = artifacts.require("WorkerNode");
var CognitiveJob = artifacts.require("CognitiveJob");
var Pandora = artifacts.require("Pandora");

module.exports = function(deployer) {
  deployer.deploy(DatasetContract, 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj', 100, 100, 1, 1);
  deployer.deploy(KernelContract, 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ', 100, 1000, 1);
};
