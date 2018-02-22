let Pandora = artifacts.require("Pandora") // *** NB: for testing use version with hooks (PandoraHooks) instead of normal contract
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  let pandora

  Pandora.deployed()
  .then(p => {
    pandora = p
    return WorkerNodeFactory.deployed()
  })
  .then(wnf => wnf.transferOwnership(Pandora.address))
  .then(_ => CognitiveJobFactory.deployed())
  .then(cjf => cjf.transferOwnership(Pandora.address))
  .then(_ => pandora.initialize())
  .catch(e => console.log(e))
}
