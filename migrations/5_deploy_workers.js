let StateMachineLib = artifacts.require("StateMachineLib")
let Pandora = artifacts.require("Pandora")
let WorkerNode = artifacts.require("WorkerNode")

module.exports = function(deployer, network, accounts) {
  deployer.link(StateMachineLib, WorkerNode)

  Pandora.deployed().then (pandora => {
    for (let no = 0; no < 3; no ++) {
      pandora.createWorkerNode()
    }
  }).catch(err => console.log(err))
}
