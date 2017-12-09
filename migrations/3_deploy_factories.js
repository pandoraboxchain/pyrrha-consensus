let CognitiveJobFactory = artifacts.require("CognitiveJobFactory");
let WorkerNodeFactory = artifacts.require("WorkerNodeFactory");

module.exports = function(deployer) {
  deployer.deploy(CognitiveJobFactory)
  deployer.deploy(WorkerNodeFactory)
}
