pragma solidity ^0.4.0;

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


    function balanceOf(address account) constant returns uint {
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

    function _transfer (int amount, address sender, address receiver) {
        if (amount < 0) throw;
        _updateBalance(sender, -amount);
        _updateBalance(receiver, amount);
        Transferred(sender, receiver, amount);
    }

    // transfer from user to user
    function transfer (int amount, address receiver) {
        _transfer(amount, msg.sender, receiver);
    }

    // delegated transfers by approved account
    function transfer_by_delegate(int amount, address sender, address receiver) {
        if (!approved_accounts[msg.sender]) throw; // check delegate is approved
        _transfer(amount, sender, receiver);
    }

    // IOU Token owner can whitelist an account
    function approve_account(address account) onlyOwner {
        approved_accounts[account] = true;
        Approved(account);
    }

}
