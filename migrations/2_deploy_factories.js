let WorkerNode = artifacts.require("WorkerNode")
let CognitiveJob = artifacts.require("CognitiveJob")
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")
let StateMachineLib = artifacts.require("StateMachineLib")

module.exports = function(deployer, network, accounts) {
  deployer.deploy(StateMachineLib)
  .then(_ => deployer.link(StateMachineLib, [ WorkerNode, CognitiveJob ]))
  .then(_ => deployer.deploy(CognitiveJobFactory))
  .then(_ => deployer.deploy(WorkerNodeFactory))
  .catch(e => console.error(e))
}
