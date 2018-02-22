let Pandora = artifacts.require("Pandora") // *** NB: for testing use version with hooks (PandoraHooks) instead of normal contract
let Kernel = artifacts.require("Kernel")
let Dataset = artifacts.require("Dataset")
let WorkerNode = artifacts.require("WorkerNode")

module.exports = function(deployer, network, accounts) {
  let pandora

  Pandora.deployed()
  .then(p => {
    pandora = p
    return WorkerNode.deployed()
  })
  .then(_ => pandora.createCognitiveJob(Kernel.address, Dataset.address))
  .then(tx => {
    console.log(tx)
//    const address = tx.logs[0].args['cognitiveJob']
//    console.log("  CognitiveJob: " + address)
  })
  .catch(e => console.log(e))
}
