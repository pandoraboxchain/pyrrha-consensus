pragma solidity ^0.4.8;

import 'Neurocoin.sol';
import 'MasternodeContract.sol';
import 'KernelContract.sol';
import 'DatasetContract.sol';
import 'HardwareContract.sol';
import 'Neurocontract.sol';

contract Neurochain is Multisig, Neurocoin {
    enum HardwareType { GPU, TPU, Android }

    uint constant masternodeLimit = 1000;

    mapping(address => MasternodeContract) masternodes;
    mapping(address => Neurocontract) public contracts;

    mapping(address => uint) lockedBalances;

    function registerMasternode(bytes pubKey) returns (MasternodeContract masternode) {
        MasternodeContract existingContract = masternodes[msg.sender];
        if (existingContract) {
            throw;
        }
        if (balances[msg.sender] < masternodeLimit) {
            throw;
        }
        MasternodeContract newContract = MasternodeContract(this, pubKey);
        masternodes[msg.sender] = newContract;
        balances[msg.sender] -= masternodeLimit;
        lockedBalances[msg.sender] = masternodeLimit;
    }

    function deployNeurocontract(KernelContract kernelContract, DatasetContract datasetContract, HardwareType hardwareType) returns (Neurocontract workContract) {
        workContract = Neurocontract(this, kernelContract, datasetContract, hardwareType);
        contracts[msg.sender] = workContract;
    }
}
