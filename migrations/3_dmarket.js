const Kernel = artifacts.require("Kernel")
const Dataset = artifacts.require("Dataset")
const Market = artifacts.require("PandoraMarket")

module.exports = function(deployer, network, accounts) {
  let market

  deployer
  .then(_ => deployer.deploy(Market))
  .then(_ => Market.deployed())
  .then(m => {
    market = m
    return deployer.deploy(Dataset, 'QmSFdikKbHCBnTRMgxcakjLQD5E6Nbmoo69YbQPM9ACXJj', 100, 100, 1, 1)
  })
  .then(_ => Dataset.deployed())
  .then(d => market.addDataset(d.address))
  .then(_ => deployer.deploy(Kernel, 'QmZ2ThDyq5jZSGpniUMg1gbJPzGk4ASBxztvNYvaqq6MzZ', 100, 1000, 1))
  .then(_ => Kernel.deployed())
  .then(k => market.addKernel(k.address))
  .catch(e => console.log(e))
}
