var Neurochain = artifacts.require("Neurochain");

var DatasetContract = artifacts.require("DatasetContract");
var KernelContract = artifacts.require("KernelContract");
var HardwareContract = artifacts.require("HardwareContract");
var MasternodeContract = artifacts.require("MasternodeContract");
var Neurocontract = artifacts.require("Neurocontract");

module.exports = function(deployer) {
    deployer.deploy(Neurochain, { gas: 8712388 });
};
