pragma solidity ^0.5.0;

import './zeppelin/token/ERC20Basic.sol';
import './PandoraRoot.sol';

interface PandoraProtocolIf is ERC20Basic {
    PandoraRoot public rootbox;
}
