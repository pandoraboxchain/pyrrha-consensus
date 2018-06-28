pragma solidity ^0.4.23;

import "../Pandora.sol";

contract PandoraHooks is Pandora {

    address[3] _workerNodeOwners;

    constructor(
        ICognitiveJobFactory _jobFactory,
        WorkerNodeFactory _nodeFactory,
        Reputation _reputation
    )
    Pandora(_jobFactory, _nodeFactory, _reputation)
    public {
    }

    function hook_whitelistedOwner(uint256 no)
    public
    view
    returns (address) {
        return _workerNodeOwners[no];
    }

    function hook_whitelistedOwnerCount()
    public
    view
    returns (uint) {
        return _workerNodeOwners.length;
    }
}
