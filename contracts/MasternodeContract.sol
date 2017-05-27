pragma solidity ^0.4.8;

/*

 */

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';
import 'Neurochain.sol';

contract MasternodeContract is Destructible {
    bytes publicKey;
    Neurochain rootNeurochain;

    function MasternodeContract (Neurochain _rootNeurochain, bytes _publicKey) {
        publicKey = _publicKey;
        rootNeurochain = _rootNeurochain;
    }
}
