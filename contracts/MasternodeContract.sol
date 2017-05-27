pragma solidity ^0.4.8;

/*

 */

import 'zeppelin-solidity/contracts/lifecycle/Destructible.sol';

contract MasternodeContract is Destructible {
    bytes publicKey;

    function MasternodeContract(bytes _publicKey){
        publicKey = _publicKey;
    }
}
