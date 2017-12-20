const Kernel = artifacts.require("Kernel")
const Dataset = artifacts.require("Dataset")
const Market = artifacts.require("PandoraMarket")

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Market)
  .then(_ => Market.deployed())
  .then(market => {
    market.addKernel(Kernel.address)
    .catch(e => console.log(e))

    market.addDataset(Dataset.address)
    .catch(e => console.log(e))
  })
}
