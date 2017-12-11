let StateMachineLib = artifacts.require("StateMachineLib")
let PAN = artifacts.require("PAN")
let Pandora = artifacts.require("Pandora")
let CognitiveJobFactory = artifacts.require("CognitiveJobFactory");
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory");

module.exports = function(deployer, network, accounts) {
  let workerOwners = [ ];

  for (var i = 0; i < accounts.length && i < 3; i++) {
    workerOwners.push(accounts[i])
  }
  for (; i < 3; i++) {
    workerOwners.push(accounts[0])
  }

  let pandora, cognitiveJobFactory, workerNodeFactory;
  deployer.deploy(StateMachineLib).then(sml => {
    return CognitiveJobFactory.deployed()
  })
  .then(cjs => {
    cognitiveJobFactory = cjs
    return WorkerNodeFactory.deployed()
  })
  .then(wnf => {
    workerNodeFactory = wnf
    deployer.link(StateMachineLib, Pandora)
    return deployer.deploy(Pandora, cognitiveJobFactory.address, workerNodeFactory.address, workerOwners)
  })
  .then(p => {
    pandora = p
    return workerNodeFactory.transferOwnership(pandora)
  })
  .then(_ => {
    return cognitiveJobFactory.transferOwnership(pandora)
  })
  .then(_ => {
    return pandora.initialize()
  })
  .catch(err => console.log(err))
}
