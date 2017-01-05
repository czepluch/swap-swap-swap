pragma solidity ^0.4.0;

//import "InterestRateOracle.sol";
//import "IOUToken.sol";

contract SwapContract {

    uint global_interest_rate;
    uint fixed_rate;
    address oracle_address;
    address IOU_token_address;
    address floating_leg_account;
    address fixed_leg_account;
    uint value_date; /// (days since 1970)
    uint maturity_date; /// (days since 1970)
    uint nominal_amount;
    uint accrual_period; ///(days)
    uint last_fixing_date; 

    //construcor

    function SwapContract(
                address _oracle_address, 
                address _floating_leg_account, 
                address _fixed_leg_account, 
                uint _value_date, 
                uint _maturity_date, 
                uint _nominal_amount, 
                uint _accrual_period, 
                address _IOU_token_address)
    {
        oracle_address = _oracle_address;
        IOU_token_address = _IOU_token_address;
        floating_leg_account = _floating_leg_account;
        fixed_leg_account = _fixed_leg_account;
        value_date = _value_date;
        maturity_date = _maturity_date;
        nominal_amount = _nominal_amount;
        accrual_period = _accrual_period;
        last_fixing_date = value_date;
    }
    
    // Check if payment is due, calculate net payment amount, initiate IOU transfer
    
    function initiatePayment() {
        uint day = now/(60*60*24);
        if (day > value_date && day < maturity_date) throw; //check whether swap is active
        if (day != last_fixing_date + accrual_period) throw; //check fixing date is matched
        last_fixing_date = day; //set date to paid
        updateInterestRate("EUR"); //query oracle for interest rate
        uint floating_leg_payment = fixed_rate/100 * nominal_amount; //calculate floating leg payment
        uint fixed_leg_payment = global_interest_rate/10000 * nominal_amount; //calculate fixed leg payment
        int net_payment_amount = int(fixed_leg_payment - floating_leg_payment); //calculate net payment amount
        IOUToken iou = IOUToken(IOU_token_address);
        if (net_payment_amount > 0) { //if net payment amount is positive
            iou.transferByDelegate(net_payment_amount, fixed_leg_account, floating_leg_account);  //pay from fixed leg tofloating leg
        }
        else{ //if net payment amount is negative
            iou.transferByDelegate(net_payment_amount*(-1), floating_leg_account, fixed_leg_account); //pay from floating leg to fixed leg
        }
        
    }
        

    function updateInterestRate(bytes32 currency) {
        InterestRateOracle iro = InterestRateOracle(oracle_address);
        global_interest_rate = iro.getInterestRate(currency);
    }

}




contract InterestRateOracle {

    function getInterestRate(bytes32 currency) returns (uint) {
        // call returnInterestRate with result from oracle
        return interestRate(currency);
    }

    function interestRate(bytes32 currency) private returns (uint) {
        if (currency == "USD") {
            return 135; // two decimal points
        } if (currency == "EUR") {
            return 129;
        } else {
            return 133;
        }
    }
}

contract IOUToken {
    mapping (address => bool) public approved_accounts;
    mapping (address => int) public balances;

    address owner;

    event Transferred(address sender, address receiver, int amount);
    event Approved(address account);

    function IOUToken() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }


    function balanceOf(address account) constant returns (int) {
        return balances[account];
    }

    // helper to check for overflows
    function _updateBalance(address account, int amount) private {
        int old_balance = balances[account];
        int new_balance = old_balance + amount;
        // Check for positive value overflow
        if (amount > 0 && new_balance < old_balance) {
            throw;
        }
        // Check for negative value overflow
        if (amount < 0 && new_balance > old_balance) {
            throw;
        }
        // Actually update the balances
        balances[account] += amount;
    }

    function _transfer(int amount, address sender, address receiver) {
        if (amount < 0) throw;
        _updateBalance(sender, -amount);
        _updateBalance(receiver, amount);
        Transferred(sender, receiver, amount);
    }

    // transfer from user to user
    function transfer(int amount, address receiver) {
        _transfer(amount, msg.sender, receiver);
    }

    // delegated transfers by approved account
    function transferByDelegate(int amount, address sender, address receiver) {
        if (!approved_accounts[msg.sender]) throw; // check delegate is approved
        _transfer(amount, sender, receiver);
    }

    // IOU Token owner can whitelist an account
    function approveAccount(address account) onlyOwner {
        approved_accounts[account] = true;
        Approved(account);
    }

}
