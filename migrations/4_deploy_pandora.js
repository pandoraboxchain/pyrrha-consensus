var StateMachineLib = artifacts.require("StateMachineLib");
var PAN = artifacts.require("PAN");
var Pandora = artifacts.require("Pandora");
var WorkerNode = artifacts.require("WorkerNode");

module.exports = function(deployer) {
  return deployer.deploy(Pandora, [
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4',
    '0x369C7F82e099aB8456B8b2d23f9ab62e4DAe3DC4'
  ], { gas: 6710000 }); /*.then(function () {
    WorkerNode.deployed().linkPandora(Pandora.deployed().address);
  });*/
};
