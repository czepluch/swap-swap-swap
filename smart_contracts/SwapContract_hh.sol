pragma solidity ^0.4.0;
import "Oracle.sol";
import "IOUToken.sol";


contract SwapContract {
    uint value_date;     // days since 1.1.1970
    uint maturity_date;  // days since 1.1.1970
    uint accural_period; // days
    uint last_fixation_date; // days since 1.1.1970
    uint nominal_value;  // num tokens as defined in contract at clearing_token_address (same for both legs)
    uint fixed_rate;    // pct * 1000
    uint rate_divisor = 100 * 1000;
    address oracle_address;// address of the floating_rate_oracle
    address floating_leg_account; //
    address fixed_leg_account; //
    address clearing_token_address; //

    function SwapContract(
        uint _value_date,
        uint _maturity_date,
        uint _accural_period,
        uint _nominal_value,
        uint _fixed_rate,
        address _oracle_address,
        address _floating_leg_account,
        address _fixed_leg_account,
        address _clearing_token_address)
    {
        value_date = _value_date;
        maturity_date = _maturity_date;
        accural_period = _accural_period;
        nominal_value = _nominal_value;
        fixed_rate = _fixed_rate;
        oracle_address = _oracle_address;
        floating_leg_account = _floating_leg_account;
        fixed_leg_account = _fixed_leg_account;
        clearing_token_address = _clearing_token_address;
        last_fixation_date = _value_date;
    }


    event Fixation(uint indexed date, uint indexed netted_payment);

    function trigger() {
        Oracle iro = Oracle(oracle_address);
        uint date = iro.getDate(); // days since 1.1.1970

        // date: days since 1.1.1970
        if (date - last_fixation_date != accural_period) throw;
        if (date > maturity_date) throw;
        if (date < value_date) throw;
        last_fixation_date = date;

        // calc fixed leg payment
        uint fixed_leg_payment = fixed_rate * nominal_value / rate_divisor;

        // calc floating leg payment
        uint floating_rate = iro.getFloatingRate(); // pct * 1000
        uint floating_leg_payment = floating_rate * nominal_value / rate_divisor;

        // calculate netted payouts
        uint netted_payment = floating_leg_payment - fixed_leg_payment;
        Fixation(date, netted_payment);  // emit here so we have implicit direction of payment
        if (netted_payment > 0) {
            address sender = floating_leg_account;
            address receiver = fixed_leg_account;
        } else {
            netted_payment = -netted_payment;
            sender = fixed_leg_account;
            receiver = floating_leg_account;
        }

        // transfer tokens
        IOUToken clearing_token = IOUToken(clearing_token_address);
        clearing_token.transferByDelegate(int(netted_payment), sender, receiver);  // token throws on failure
    }
}
