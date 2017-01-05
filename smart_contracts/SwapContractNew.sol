pragma solidity ^0.4.0;

import "Oracle.sol";
import "IOUToken.sol";

contract SwapContract {

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
                uint _fixed_rate,
                address _oracle_address, 
                address _floating_leg_account, 
                address _fixed_leg_account, 
                uint _value_date, 
                uint _maturity_date, 
                uint _nominal_amount, 
                uint _accrual_period, 
                address _IOU_token_address)
    {
        fixed_rate = _fixed_rate;
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
        Oracle oracle = Oracle(oracle_address);
        uint day = oracle.getDate();
        if (day < value_date && day > maturity_date) throw; //check whether swap is active
        if (day != last_fixing_date + accrual_period) throw; //check fixing date is matched
        last_fixing_date = day; //set date to paid
        uint floating_rate= oracle.getRate(); //query oracle for interest rate
        uint floating_leg_payment = fixed_rate * (nominal_amount / 10000); //calculate floating leg payment
        uint fixed_leg_payment = floating_rate * (nominal_amount / 10000); //calculate fixed leg payment
        int net_payment_amount = int(fixed_leg_payment - floating_leg_payment); //calculate net payment amount
        IOUToken iou = IOUToken(IOU_token_address);
        if (net_payment_amount > 0) { //if net payment amount is positive
            iou.transferByDelegate(net_payment_amount, fixed_leg_account, floating_leg_account);  //pay from fixed leg tofloating leg
        }
        else{ //if net payment amount is negative
            iou.transferByDelegate(net_payment_amount*(-1), floating_leg_account, fixed_leg_account); //pay from floating leg to fixed leg
        }
    }
}
