let Pandora = artifacts.require("PandoraHooks") // *** NB: version with hooks (for testing) instead of normal contract)
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory")
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory")
let WorkerNode = artifacts.require("WorkerNode")
let Kernel = artifacts.require("Kernel")
let Dataset = artifacts.require("Dataset")

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
  .then(tx => {
    const address = tx.logs[0].args['workerNode']
    console.log("  WorkerNode: " + address)
    return WorkerNode.at(address)
  })
  .then(workerNode => workerNode.alive())
  .then(_ => pandora.createCognitiveJob(Kernel.address, Dataset.address))
  .catch(e => console.log(e))
}
