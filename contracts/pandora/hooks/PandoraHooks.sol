pragma solidity 0.4.23;

import "../Pandora.sol";

contract PandoraHooks is Pandora {

    address[3] _workerNodeOwners;

    constructor(
        CognitiveJobFactory _jobFactory,
        WorkerNodeFactory _nodeFactory
    )
    Pandora(_jobFactory, _nodeFactory)
    public {
    }

    function hook_whitelistedOwner(uint256 no)
    public
    returns (address) {
        return _workerNodeOwners[no];
    }

    function hook_whitelistedOwnerCount()
    public
    returns (uint) {
        return _workerNodeOwners.length;
    }

    function hook_resetAllWorkers()
    public {

    }
}
