pragma solidity ^0.4.0;

contract Oracle {

    uint public date;
    uint public rate;
    address owner;

    function Oracle() {
        owner = msg.sender;
    };

    function update(_date, _rate) {
        if (msg.sender != owner) throw;
        date = _date;
        rate = _rate;
    }
}
