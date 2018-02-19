let Pandora = artifacts.require("Pandora") // *** NB: for testing use version with hooks (PandoraHooks) instead of normal contract
let Kernel = artifacts.require("Kernel")
let Dataset = artifacts.require("Dataset")

module.exports = function(deployer, network, accounts) {
  Pandora.deployed()
  //.then(pandora => pandora.createCognitiveJob(Kernel.address, Dataset.address))
  .catch(e => console.log(e))
}
