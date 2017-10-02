var StateMachineLib = artifacts.require("StateMachineLib");
var PAN = artifacts.require("PAN");
var Pandora = artifacts.require("Pandora");
var WorkerNode = artifacts.require("WorkerNode");

module.exports = function(deployer) {
  let workers = [];
  for (let i = 0; i < 7; i++) {
    workers.push(WorkerNode.address);
  }
  deployer.deploy(Pandora, workers, { gas: 6710000 }).then(function () {
    return WorkerNode.deployed()
  }).then (function (workerNode) {
    workerNode.linkPandora(Pandora.address);
  });
};
