let Pandora = artifacts.require("Pandora")
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")

module.exports = function(deployer, network, accounts) {
  WorkerNodeFactory.deployed().then(factory => factory.transferOwnership(Pandora.address)).catch(e => console.log(e))
  CognitiveJobFactory.deployed().then(factory => factory.transferOwnership(Pandora.address)).catch(e => console.log(e))
}
