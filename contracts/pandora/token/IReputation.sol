pragma solidity ^0.4.24;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract IReputation is Ownable {

    mapping(address => uint256) public values;

    function incrReputation(address account, uint256 amount) public;

    function decrReputation(address account, uint256 amount) public;
}
