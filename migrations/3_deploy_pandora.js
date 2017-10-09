let StateMachineLib = artifacts.require("StateMachineLib")
let PAN = artifacts.require("PAN")
let Pandora = artifacts.require("Pandora")
let WorkerNode = artifacts.require("WorkerNode")

module.exports = function(deployer, network, accounts) {
  let workerOwners = [ ];

  for (var i = 0; i < accounts.length && i < 7; i++) {
    workerOwners.push(accounts[i])
  }
  for (; i < 7; i++) {
    workerOwners.push(accounts[0])
  }

  deployer.deploy(StateMachineLib)
  deployer.link(StateMachineLib, Pandora)
  deployer.link(StateMachineLib, WorkerNode)

  deployer.deploy(Pandora, workerOwners, { gas: 16710000 }).then(function () {
    return Pandora.deployed()
  }).then (function (pandora) {
    for (let no = 0; no < 7; no ++) {
      pandora.createWorkerNode()
    }
  })
}
