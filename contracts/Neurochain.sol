pragma solidity ^0.4.8;

import 'Neurocoin.sol';
import 'MasternodeContract.sol';
import 'KernelContract.sol';
import 'DatasetContract.sol';
import 'HardwareContract.sol';
import 'Neurocontract.sol';

contract Neurochain is Multisig, Neurocoin {
    enum HardwareType { GPU, TPU, Android }

    MasternodeContract[] masternodes;
    mapping(address => Neurocontract) public contracts;

    function deployNeurocontract(KernelContract kernelContract, DatasetContract datasetContract, HardwareType hardwareType) returns (Neurocontract workContract) {
        workContract = Neurocontract(this, kernelContract, datasetContract, hardwareType);
        contracts[msg.sender] = workContract;
    }
}
