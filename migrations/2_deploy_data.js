var DatasetContract = artifacts.require("Dataset");
var KernelContract = artifacts.require("Kernel");
var WorkerNode = artifacts.require("WorkerNode");
var CognitiveJob = artifacts.require("CognitiveJob");
var Pandora = artifacts.require("Pandora");

module.exports = function(deployer) {
  deployer.deploy(DatasetContract, 'QmNxi5m9oZekHcfddayPwKNmsFfBGAP39CZXSnjnC2yF6B', 100, 100, 1, 1);
  deployer.deploy(KernelContract, 'QmNxi5m9oZekHcfddayPwKNmsFfBGAP39CZXSnjnC2yF6B', 100, 1000, 1);
//  deployer.deploy(KernelContract, 'QmPhtLgduZaCJFQ4SReNMDnHo7Lb6YyVQU1wCiJdvw6CJa', 'QmQuHbEaQem2KGHwgpcZs7dHMeu8sm4npjbDA8NRXLPfPo', 1);
};
