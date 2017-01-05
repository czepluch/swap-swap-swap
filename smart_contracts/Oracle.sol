pragma solidity ^0.4.0;

contract Oracle {

    uint public date;
    uint public rate;
    address public owner;

    function Oracle() {
        owner = msg.sender;
    }

    function update(uint _date, uint _rate) {
        if (msg.sender != owner) throw;
        date = _date;
        rate = _rate;
    }

    function getDate() constant returns (uint) {
        return date;
    }

    function getRate() constant returns (uint) {
        return rate;
    }
}
