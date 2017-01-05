pragma solidity ^0.4.0;

contract Oracle {

    uint public date;
    uint public rate;
    address public owner;

    function Oracle() {
        owner = msg.sender;
        date = now;
        rate = 123;
    }

    function update(uint _date, uint _rate) {
        if (msg.sender != owner) throw;
        date = _date;
        rate = _rate;
    }
}
