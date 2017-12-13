let Pandora = artifacts.require("PandoraHooks") // *** NB: version with hooks (for testing) instead of normal contract)
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  let pandora;

  WorkerNodeFactory.deployed()
  .then(wnf => wnf.transferOwnership(Pandora.address))
  .then(_ => CognitiveJobFactory.deployed())
  .then(cjf => cjf.transferOwnership(Pandora.address))
  .then(_ => Pandora.deployed())
  .then(p => {
    pandora = p
    return pandora.initialize()
  })
  .then(_ => pandora.createWorkerNode({ from: accounts[0] }))
  .catch(e => console.log(e))
}
