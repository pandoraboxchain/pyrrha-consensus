const Kernel = artifacts.require("Kernel")
const Dataset = artifacts.require("Dataset")
const Market = artifacts.require("PandoraMarket")

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Market)
  .then(_ => deployer.deploy(Dataset, 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj', 100, 100, 1, 1))
  .then(_ => deployer.deploy(Kernel, 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ', 100, 1000, 1))
  .then(_ => Market.deployed())
  .then(market => {
    market.addKernel(Kernel.address)
    .catch(e => console.log(e))

    market.addDataset(Dataset.address)
    .catch(e => console.log(e))
  })
}
