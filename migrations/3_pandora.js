let Pandora = artifacts.require("Pandora") // *** NB: version with hooks (for testing) instead of normal contract)
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  let workerOwners = [ accounts[0], accounts[1], accounts[2] ]

  deployer.deploy(Pandora, CognitiveJobFactory.address, WorkerNodeFactory.address, workerOwners)
  .catch(e => console.error(e))
}
