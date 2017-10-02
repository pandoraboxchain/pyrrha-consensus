var StateMachineLib = artifacts.require("StateMachineLib");
var Pandora = artifacts.require("Pandora");
var WorkerNode = artifacts.require("WorkerNode");

module.exports = function(deployer) {
  deployer.deploy(StateMachineLib);
  deployer.link(StateMachineLib, WorkerNode);
  for (var i = 0; i < 1; ++i) {
    deployer.deploy(WorkerNode, 0, {gas: 6710000});
  }
};
