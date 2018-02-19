let Pandora = artifacts.require("Pandora") // *** NB: for testing use version with hooks (PandoraHooks) instead of normal contract
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  WorkerNodeFactory.deployed()
  .then(wnf => wnf.transferOwnership(Pandora.address))
  .then(_ => CognitiveJobFactory.deployed())
  .then(cjf => cjf.transferOwnership(Pandora.address))
  .then(_ => Pandora.deployed())
  .then(p => p.initialize())
  .catch(e => console.log(e))
}
