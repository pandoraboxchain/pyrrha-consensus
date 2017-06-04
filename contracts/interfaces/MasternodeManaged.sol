pragma solidity ^0.4.8;

contract MasternodeManaged {

    mapping(address => bool) masternodes;

    modifier onlyMasternodes() {
        if (masternodes[msg.sender] != true) {
            throw;
        }
        _;
    }
}
