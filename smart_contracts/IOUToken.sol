pragma solidity ^0.4.0;

contract IOUToken {
    mapping (address => bool) public approved_accounts;
    mapping (address => int) public balances;

    address owner;

    event Transferred(address sender, address receiver, int amount);
    event Approved(address account);
    event Disapproved(address account);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        } else {
            _;
        }
    }

    function IOUToken() {
        owner = msg.sender;
    }

    // transfer from user to user
    function transfer(int amount, address receiver) {
        _transfer(amount, msg.sender, receiver);
    }

    function _transfer(int amount, address sender, address receiver) private {
        if (amount < 0) throw;
        updateBalance(sender, -amount);
        updateBalance(receiver, amount);
        Transferred(sender, receiver, amount);
    }

    // delegated transfers by approved account
    function transfer_by_delegate(int amount, address sender, address receiver) {
        if (!approved_accounts[msg.sender]) throw; // check delegate is approved
        _transfer(amount, sender, receiver);
    }

    function updateBalance(address account, int amount) private {
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

    // IOU Token owner can whitelist an account
    function approve_account(address account) onlyOwner {
        approved_accounts[account] = true;
        Approved(account);
    }

    // IOU Token owner can unwhitelist an account
    function disapprove_account(address account) onlyOwner {
        approved_accounts[account] = false;
        Disapproved(account);
    }
}
