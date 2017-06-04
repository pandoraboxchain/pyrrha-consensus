pragma solidity ^0.4.8;

/*

 */

import './zeppelin/lifecycle/Destructible.sol';

contract MasternodeContract is Destructible {
    bytes publicKey;
    address rootNeurochain;

    function MasternodeContract (address _rootNeurochain, bytes _publicKey) {
        publicKey = _publicKey;
        rootNeurochain = _rootNeurochain;
    }
}
