let Pandora = artifacts.require("PandoraHooks") // *** NB: version with hooks (for testing) instead of normal contract)
let Dataset = artifacts.require("Dataset")
let Kernel = artifacts.require("Kernel")
let IWorkerNode = artifacts.require("IWorkerNode")
let CognitiveJob = artifacts.require("CognitiveJob")

contract('Pandora', accounts => {

  it("shouldn't create cognitive contract from outside of Pandora", function() {
    let pandora

    Pandora.deployed()
    .then(p => {
      pandora = p
      return pandora.workerNodes(0)
    })
    .then(workerNode => deployer.deploy(CognitiveJob, pandora.address, Kernel.address, Dataset.address, [ workerNode.address ]))
    .then(receipt => console.log(receipt))
  })
})