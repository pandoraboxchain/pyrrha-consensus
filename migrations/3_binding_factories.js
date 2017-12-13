let Pandora = artifacts.require("Pandora")
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  WorkerNodeFactory.deployed()
  .then(wnf => wnf.transferOwnership(Pandora.address))
  .then(_ => CognitiveJobFactory.deployed())
  .then(cjf => cjf.transferOwnership(Pandora.address))
  .then(_ => Pandora.deployed())
  .then(pandora => pandora.initialize())
  .catch(e => console.log(e))
}
