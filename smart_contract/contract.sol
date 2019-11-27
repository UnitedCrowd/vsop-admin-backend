pragma solidity ^0.4.25;

library SafeMath
{
	function mul(uint256 a, uint256 b) internal pure
	returns (uint256)
	{
		uint256 c = a * b;

		assert(a == 0 || c / a == b);

		return c;
	}

	function div(uint256 a, uint256 b) internal pure
	returns (uint256)
	{
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure
	returns (uint256)
	{
		assert(b <= a);

		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure
	returns (uint256)
	{
		uint256 c = a + b;

		assert(c >= a);

		return c;
	}
}

contract ERC20
{
	function totalSupply() public view returns (uint256);
	function balanceOf(address who) public view returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable
{
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	constructor(address _owner) public
	{
		owner = _owner;
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

contract SimpleToken is ERC20, Ownable
{
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint256 public totalSupply;
	uint256 public decimals = 18;

	mapping(address => uint256) balances;
	mapping (address => mapping (address => uint256)) internal allowed;

	constructor(string _name, string _symbol, uint256 _totalSupply, address _owner) Ownable(_owner) public
	{
		name = _name;
		symbol = _symbol;
		totalSupply = _totalSupply * uint256(10**decimals);
		balances[_owner] = totalSupply;
	}

	function totalSupply() public view returns (uint256)
	{
		return totalSupply;
	}

	function _transfer(address _from, address _to, uint256 _value) internal
	{
		require(_to != address(0));
		require(balances[_from] >= _value);
		require(balances[_to].add(_value) > balances[_to]);

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(_from, _to, _value);
	}

	function transfer(address _to, uint256 _value) public returns (bool)
	{
		_transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public view returns (uint256 balance)
	{
		return balances[_owner];
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
	{
		require(_to != address(0));
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool)
	{
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public view returns (uint256)
	{
		return allowed[_owner][_spender];
	}

	function increaseApproval(address _spender, uint _addedValue) public returns (bool)
	{
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool)
	{
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}
}

contract VestableToken is SimpleToken
{
	using SafeMath for uint256;

	struct VestingDetail
	{
		address employee;
		uint256 startDate;
		uint256 cliffDate;
		uint256 durationSec;
		uint256 released;
		uint256 fullyVestedAmount;
		bool isRevokable;
		bool revoked;
	}

	address vestingTokenWallet;

	uint256 totalEmployees;
	uint256 totalTokensAvailableToGrant;
	uint256 totalBonusIssued;

	mapping (address => VestingDetail) vestingDetails;
	mapping (address => bool) alreadyVested;
	mapping (address => uint256) bonusGiven;

	// emitted when new employee added
	event logVestingScheduleCreated(address indexed employee, uint256 startDate, uint256 cliffDate, uint256 durationSec, uint256 fullyVestedAmount, bool isRevokable);

	// emitted when vesting revoked - all pending tokens are given out, no further vesting done
	event logVestingScheduleRevoked(address indexed employee);

	// emitted when tokens released
	event logVestingTokenReleased(address indexed employee, uint256 amount);

	// emitted when bonus tokens granted
	event logBonusTokensGranted(address indexed employee, uint256 amount);

	constructor(string _name, string _symbol, uint256 _totalSupply, address _owner)  SimpleToken(_name, _symbol, _totalSupply, _owner) public
	{
		vestingTokenWallet = _owner;
		totalTokensAvailableToGrant = totalSupply;
	}

	// lets admin add a employee vesting schedule
	function grantVestedTokens(address employee, uint256 fullyVestedAmount, uint256 startDate, uint256 cliffSec, uint256 durationSec, bool isRevokable) public onlyOwner returns(bool) // 0 indicates start "now"
	{
		require(employee != address(0));
		require (!alreadyVested[employee]);
		require(durationSec >= cliffSec);
		require (fullyVestedAmount <= totalTokensAvailableToGrant);

		uint256 _startDate = startDate;
		if (_startDate == 0)
		{
			_startDate = now;
		}

		uint256 cliffDate = _startDate.add(cliffSec);

		vestingDetails[employee] = VestingDetail(employee, _startDate, cliffDate, durationSec, 0, fullyVestedAmount, isRevokable, false);
		alreadyVested[employee] = true;

		totalTokensAvailableToGrant = totalTokensAvailableToGrant.sub(fullyVestedAmount);
		totalEmployees += 1;
		emit logVestingScheduleCreated(employee, _startDate, cliffDate, durationSec, fullyVestedAmount, isRevokable);
		return true;
  	}

	// lets admin assign bonus tokens to an employee
  	function grantBonusTokens(address employee, uint256 amount) external onlyOwner returns(bool)
  	{
		_transfer(vestingTokenWallet, employee, amount);
		totalBonusIssued += amount;
		bonusGiven[employee] += amount;
		emit logBonusTokensGranted(employee, amount);
  	}

	// lets admin remove a employee vesting schedule
	function revokeVesting(address employee) public onlyOwner returns (bool)
	{
		require(employee != address(0));
		require (vestingDetails[employee].isRevokable == true);

		totalTokensAvailableToGrant = totalTokensAvailableToGrant.add(vestingDetails[employee].fullyVestedAmount.sub(releasableAmount(employee)));
		releaseVestedTokens(employee);
		vestingDetails[employee].revoked = true;
		alreadyVested[employee] = false;

		totalEmployees -= 1;
		emit logVestingScheduleRevoked(employee);
		return true;
	}

	function releaseVestedTokens(address employee) public returns (bool)
	{
		require(employee != address(0));
		require(vestingDetails[employee].revoked == false);

		uint256 unreleased = releasableAmount(employee);

		if (unreleased == 0)
		{
			return true;
		}

		vestingDetails[employee].released = vestingDetails[employee].released.add(unreleased);
		_transfer(vestingTokenWallet, employee, unreleased);
		emit logVestingTokenReleased(employee, unreleased);
		return true;
	}

	function releasableAmount(address employee) public view returns (uint256)
	{
		return getVestedAmount(employee).sub(vestingDetails[employee].released);
	}

	function getVestedAmount(address employee) public view returns (uint256)
	{
		uint256 totalBalance = vestingDetails[employee].fullyVestedAmount;

		if (block.timestamp < vestingDetails[employee].cliffDate)
		{
			return 0;
		}
		else if (block.timestamp >= vestingDetails[employee].startDate.add(vestingDetails[employee].durationSec))
		{
			return totalBalance;
		}
		else
		{
			return totalBalance.mul(block.timestamp.sub(vestingDetails[employee].startDate)).div(vestingDetails[employee].durationSec);
		}
	}

	function getTotalEmployees() public view returns (uint256)
	{
		return totalEmployees;
	}

	function getAvlblTokens() public view returns (uint256)
	{
		return totalTokensAvailableToGrant;
	}

	function getTotalBonusIssued() public view returns (uint256)
	{
		return totalBonusIssued;
	}

	function getEmployeeSpecs(address employee) public view returns(uint256 r_startDate, uint256 r_cliffDate, uint256 r_durationSec, uint256 r_released, uint256 r_fullyVestedAmount, uint256 r_bonus, bool r_isRevokable, bool r_revoked)
	{
		r_startDate = vestingDetails[employee].startDate;
		r_cliffDate = vestingDetails[employee].cliffDate;
		r_durationSec = vestingDetails[employee].durationSec;
		r_released = vestingDetails[employee].released;
		r_fullyVestedAmount = vestingDetails[employee].fullyVestedAmount;
		r_bonus = bonusGiven[employee];
		r_isRevokable = vestingDetails[employee].isRevokable;
		r_revoked = vestingDetails[employee].revoked;
	}
}
