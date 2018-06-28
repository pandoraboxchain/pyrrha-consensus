pragma solidity ^0.4.23;

import "./ICognitiveJobFactory.sol";
import "../../jobs/CognitiveJob.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IDataset.sol";
import "../../entities/IKernel.sol";
import "../../nodes/IWorkerNode.sol";
import "../IPandora.sol";

contract CognitiveJobFactory is ICognitiveJobFactory {
    constructor() public { }

    function create(
        IKernel _kernel,
        IDataset _dataset,
        IWorkerNode[] _workersPool,
        uint256 _complexity,
        bytes32 _description
    )
    onlyOwner
    external
    returns (CognitiveJob o_cognitiveJob) {
        // Creating job
        o_cognitiveJob = new CognitiveJob(
            IPandora(owner), _kernel, _dataset, _workersPool, _complexity, _description);

//        // Checking that it was created correctly
//        assert(o_cognitiveJob != CognitiveJob(0));

        // Transferring ownership to the main Pandora contract (which owns this factory)
        o_cognitiveJob.transferOwnership(owner);
    }
}
