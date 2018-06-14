pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

contract Reputation is Ownable {

	mapping(address => uint256) public values;

	constructor() {
		owner = msg.sender;
	}

	function incrReputation(address account, uint256 amount) onlyOwner {
		assert(values[account] + amount >= values[account]);
		values[account] + amount;
	}

	function decrReputation(address account, uint256 amount) onlyOwner {
		if (values[account] - amount < values[account]) {
			values[account] -= amount;
		} else {
			values[account] = 0;
		}
	}
}