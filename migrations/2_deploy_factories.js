let Pandora = artifacts.require("Pandora")
let WorkerNode = artifacts.require("WorkerNode")
let CognitiveJob = artifacts.require("CognitiveJob")
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")
let StateMachineLib = artifacts.require("StateMachineLib")

module.exports = function(deployer, network, accounts) {
  let workerOwners = [ accounts[0], accounts[1], accounts[2] ]

  deployer.deploy(StateMachineLib)
  .then(_ => deployer.link(StateMachineLib, [ WorkerNode, CognitiveJob ]))
  .then(_ => deployer.deploy(CognitiveJobFactory))
  .then(_ => deployer.deploy(WorkerNodeFactory))
  .then(_ => deployer.deploy(Pandora, CognitiveJobFactory.address, WorkerNodeFactory.address, workerOwners))
  .catch(e => console.error(e))
}
