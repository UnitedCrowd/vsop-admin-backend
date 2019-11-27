pragma solidity ^0.4.25;

contract Ownable
{
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor() public
	{
		owner = msg.sender;
	}

	modifier onlyOwner()
	{
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner
	{
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

contract RoT is Ownable{
	address public ESOPAddress;

	event ESOPSet(address ESOPAddress);

	function setESOP(address ESOP) public onlyOwner {
		ESOPAddress = ESOP;
		emit ESOPSet(ESOP);
	}

	function killOnUnsupportedFork() public onlyOwner {
		delete ESOPAddress;
		selfdestruct(owner);
	}
}
