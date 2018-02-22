const Pandora = artifacts.require("Pandora")
const WorkerNode = artifacts.require("WorkerNode")
const CognitiveJob = artifacts.require("CognitiveJob")
const CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
const WorkerNodeFactory = artifacts.require("WorkerNodeFactory")
const StateMachineLib = artifacts.require("StateMachineLib")

module.exports = function(deployer, network, accounts) {
  let lastAccount = accounts[0]
  let workerOwners = [ ]
  for (let i = 1; i <= 3; i++) {
    workerOwners.push(lastAccount)
    if (accounts[i]) {
      lastAccount = accounts[i]
    }
  }

  let pandora, wnf, cjf

  deployer
  .then(_ => deployer.deploy(StateMachineLib))
  .then(_ => deployer.link(StateMachineLib, [ WorkerNode, CognitiveJob ]))
  .then(_ => {
    return deployer.deploy(CognitiveJobFactory)
  })
  .then(_ => CognitiveJobFactory.deployed())
  .then(instance => {
    cjf = instance
    return deployer.deploy(WorkerNodeFactory)
  })
  .then(_ => WorkerNodeFactory.deployed())
  .then(instance => {
    wnf = instance
    return deployer.deploy(Pandora, cjf.address, wnf.address, workerOwners)
  })
  .then(_ => Pandora.deployed())
  .then(instance => {
    pandora = instance
    return wnf.transferOwnership(pandora.address)
  })
  .then(_ => cjf.transferOwnership(pandora.address))
  .then(_ => pandora.initialize())
  .catch(e => console.error(e))
}
