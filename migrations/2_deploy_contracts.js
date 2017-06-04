var Neurochain = artifacts.require("./Neurochain.sol");

var DatasetContract = artifacts.require("./DatasetContract.sol");
var KernelContract = artifacts.require("./KernelContract.sol");
var HardwareContract = artifacts.require("./HardwareContract.sol");
var MasternodeContract = artifacts.require("./MasternodeContract.sol");
var Neurocontract = artifacts.require("./Neurocontract.sol");

module.exports = function(deployer) {
  deployer.deploy(Neurochain);

  /*
  deployer.deploy(DatasetContract, 'QmNxi5m9oZekHcfddayPwKNmsFfBGAP39CZXSnjnC2yF6B', 7, 1);
  deployer.deploy(KernelContract, 'QmPhtLgduZaCJFQ4SReNMDnHo7Lb6YyVQU1wCiJdvw6CJa', 'QmQuHbEaQem2KGHwgpcZs7dHMeu8sm4npjbDA8NRXLPfPo', 1);
  deployer.deploy(HardwareContract, 'localhost:50051', 1);
  */
};
