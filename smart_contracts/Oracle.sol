pragma solidity ^0.4.0;

contract Oracle {

    uint public day;
    uint public rate;
    address owner;

    function Oracle() {
        owner = msg.sender;
    };

    function update(_day, _rate) {
        if (msg.sender != owner) throw;
        day = _day;
        rate = _rate;
    }
}
