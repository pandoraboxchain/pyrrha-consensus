let StateMachineLib = artifacts.require("StateMachineLib")
let PAN = artifacts.require("PAN")
let Pandora = artifacts.require("Pandora")
let WorkerNode = artifacts.require("WorkerNode")

module.exports = function(deployer) {
  let workerOwners = [
    '0x08371642F2f29d714104672b130ab9F1F162890c',
    '0xcc36859f9c41fb5a8df30d123b55cc53fd2a0452',
    '0x1cf55c855a9dc472f497b92f1e3903a92f3319dd',
    '0xc30c776cd7f8959684a829291bfc1b6b04d1f126',
    '0xdddb219b2e3a9c6fdbdb594772608bebca41a0f6',
    '0xc66f6b10dd9a99b50e9f0f4bf9ea028342afb529',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B'
  ]

  deployer.deploy(StateMachineLib)
  deployer.link(StateMachineLib, Pandora)
  deployer.link(StateMachineLib, WorkerNode)

  deployer.deploy(Pandora, workerOwners, { gas: 16710000 }).then(function () {
    return Pandora.deployed()
  }).then (function (pandora) {
    for (let i = 0; i < 7; i ++) {
      pandora.createWorkerNode()
    }
  })
}
