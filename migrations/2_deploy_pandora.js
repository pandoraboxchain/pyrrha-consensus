var Pandora = artifacts.require("Pandora");
var WorkerNode = artifacts.require("WorkerNode");

module.exports = function(deployer) {
  deployer.deploy(Pandora, [
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B',
    '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B'
  ], { from: '0x549c05D76DaFBf452a34b97E7005D209Bf07bc7B', gas: 8712388 });
};
