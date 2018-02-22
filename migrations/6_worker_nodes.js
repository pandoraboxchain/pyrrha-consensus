let Pandora = artifacts.require("Pandora") // *** NB: for testing use version with hooks (PandoraHooks) instead of normal contract
let WorkerNode = artifacts.require("WorkerNode")
const Kernel = artifacts.require("Kernel")
const Dataset = artifacts.require("Dataset")

function createWorkerForAccount(pandora, account)
{
  return pandora.createWorkerNode({ from: account })
  .then(tx => {
    const address = (tx.logs[1]|| tx.logs[0])mv .args['workerNode']
    console.log("  WorkerNode: " + address)
    return WorkerNode.at(address)
  })
  .then(workerNode => workerNode.alive())
}

module.exports = function(deployer, network, accounts) {
  let pandora

  return Pandora.deployed()
  .then(p => {
    pandora = p
    return createWorkerForAccount(pandora, accounts[0])
  })
  .then(_ => pandora.createCognitiveJob(Kernel.address, Dataset.address))
  .then(_ => createWorkerForAccount(pandora, accounts[1]))
  .then(_ => createWorkerForAccount(pandora, accounts[2]))
  .catch(e => console.log(e))
}
