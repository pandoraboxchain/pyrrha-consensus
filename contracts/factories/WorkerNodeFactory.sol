pragma solidity ^0.4.0;

import '../Pandora.sol';
import '../WorkerNode.sol';

contract WorkerNodeFactory {
    function WorkerNodeFactory() {}

    function create(
        Pandora _pandora /// Reference to the main Pandora contract that creates Worker Node
    ) returns (WorkerNode) {
        return new WorkerNode(_pandora);
    }
}
