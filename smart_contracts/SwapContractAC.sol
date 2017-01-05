pragma solidity ^0.4.2;

contract SwapContract {
    uint256 _startDate;
    uint256 _maturityDate;
    uint256 _nominalAmount;
    uint256 _interval;
    FixedLeg _fixedLeg;
    FloatingLeg _floatingLeg;
    address _flrp;
    address _firp;
    SwapToken _swapToken;
    InterestRateOracle _interestRateOracle;
    
    struct FixedLeg {
        uint256 rate;
    }
    
    struct FloatingLeg {
        address allowedOracle;
        uint256 spread;
    }
    
	function SwapContract(address flrp, address firp, uint256 startDate, uint256 maturityDate, uint256 nominalAmount, uint256 fixedRate, uint256 interval, uint256 spread, address oracle) {
		_swapToken = SwapToken(0x4fec1f3f09c1033e17d61f07e6aa2fdcd7dfe4ef);
		_interestRateOracle = InterestRateOracle(0x92baa33be8fa354cb7b8716a1e6f2f90b4f84498);
		_flrp = flrp;
		_firp = firp; 
		_startDate = startDate;
		_maturityDate = maturityDate;
		_nominalAmount = nominalAmount;
		_interval = interval;
		_fixedLeg = FixedLeg({rate:fixedRate});
		_floatingLeg = FloatingLeg({allowedOracle:oracle, spread:spread});
	}

	function execute() returns (bool sufficient) {
	    //if (now >= start + daysAfter * 1 days) {}
	    uint256 floatingRate = _interestRateOracle.getInterestRate("EUR");
	    uint256 floatingRatePayment = _nominalAmount * ((floatingRate + _floatingLeg.spread) / 100);
	    _swapToken.transferFrom(_flrp, _firp, floatingRatePayment);
	    _swapToken.transferFrom(_firp, _flrp, _fixedLeg.rate);
	    return true;
	}

}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract InterestRateOracle {
    function getInterestRate(bytes32 currency) returns (uint256) {
        return 2;
    }
}

contract SwapToken {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function SwapToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol
        ) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        totalSupply = initialSupply;                        // Update total supply
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    /* Allow another contract to spend some tokens in your behalf */
    function approve(address _spender, uint256 _value)
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /* Approve and then comunicate the approved contract in a single tx */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }        

    /* A contract attempts to get the coins */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balanceOf[_from] < _value) throw;                 // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;  // Check for overflows
        if (_value > allowance[_from][msg.sender]) throw;   // Check allowance
        balanceOf[_from] -= _value;                          // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
