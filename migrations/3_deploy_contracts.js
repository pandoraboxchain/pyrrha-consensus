var DatasetContract = artifacts.require("DatasetContract");
var KernelContract = artifacts.require("KernelContract");
var HardwareContract = artifacts.require("HardwareContract");
var MasternodeContract = artifacts.require("MasternodeContract");
var Neurocontract = artifacts.require("Neurocontract");

module.exports = function(deployer) {
  deployer.deploy(DatasetContract, 'QmNxi5m9oZekHcfddayPwKNmsFfBGAP39CZXSnjnC2yF6B', 7, 1);
  deployer.deploy(KernelContract, 'QmPhtLgduZaCJFQ4SReNMDnHo7Lb6YyVQU1wCiJdvw6CJa', 'QmQuHbEaQem2KGHwgpcZs7dHMeu8sm4npjbDA8NRXLPfPo', 1);
  deployer.deploy(HardwareContract, 'localhost:50051', 1);
};
