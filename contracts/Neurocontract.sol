pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';
import './interfaces/MasternodeManaged.sol';
import './KernelContract.sol';
import './DatasetContract.sol';
import './HardwareContract.sol';

contract Neurocontract is Destructible, MasternodeManaged {
    KernelContract public kernelContract;
    DatasetContract public datasetContract;
    HardwareContract.Type public compatibility;
    address public rootNeurochain;

    uint public completedSamplesCount;

    function Neurocontract(
        address _rootNeurochain,
        KernelContract _kernelContract,
        DatasetContract _datasetContract,
        HardwareContract.Type _hardwareType
    ) {
        completedSamplesCount = 0;
        rootNeurochain = _rootNeurochain;
        kernelContract = _kernelContract;
        datasetContract = _datasetContract;
        compatibility = _hardwareType;
        //this.prepayWork();
    }

    function prepayWork() payable onlyOwner {
        // TODO: Check that payment is sufficient for the task completion
        startWork();
    }

    function startWork() private onlyOwner {

    }

    function commitWork(uint processedAmount) onlyMasternodes {
        completedSamplesCount += processedAmount;
    }
}
