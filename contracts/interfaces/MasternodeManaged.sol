pragma solidity ^0.4.8;

import '../MasternodeContract.sol';

contract MasternodeManaged {
    mapping(MasternodeContract => bool) masternodes;

    modifier onlyMasternodes() {
        if (masternodes[msg.sender] != true) {
            throw;
        }
        _;
    }
}
