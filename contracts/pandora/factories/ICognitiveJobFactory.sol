pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../../jobs/CognitiveJob.sol";
import "../../entities/IDataEntity.sol";
import "../../entities/IDataset.sol";
import "../../entities/IKernel.sol";
import "../../nodes/IWorkerNode.sol";

contract ICognitiveJobFactory is Ownable {
    function create(
        IKernel _kernel,
        IDataset _dataset,
        IWorkerNode[] _workersPool,
        uint256 _complexity,
        bytes32 _description
    )
    external
    returns (CognitiveJob o_cognitiveJob);
}
