pragma solidity ^0.4.18;

import "../Pandora.sol";

contract PandoraHooks is Pandora {
    function PandoraHooks(
        CognitiveJobFactory _jobFactory,
        WorkerNodeFactory _nodeFactory,
        address[3] _workerNodeOwners
    )
    Pandora(_jobFactory, _nodeFactory, _workerNodeOwners)
    public {
    }

    function hook_whitelistedOwner(uint no) returns (address) {
        return workerNodeOwners[no];
    }

    function hook_whitelistedOwnerCount() returns (uint) {
        return workerNodeOwners.length;
    }
}
