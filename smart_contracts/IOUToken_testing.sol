pragma solidity ^0.4.0;
import "IOUToken.sol";

contract IOUToken_testing is IOUToken {

    function balance(address account) constant returns(int) {
        return balances[account];
    }

    function is_approved(address account) constant returns(bool) {
        return approved_accounts[account];
    }
}
