pragma solidity ^0.4.7;

contract Owned {
    address owner;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        } else {
            _;
        }
    }

    function Owned() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract IOUToken is Owned {
    mapping (address => bool) public approved_accounts;
    mapping (address => int) public balances;

    event TransferredDirectly(address sender, address receiver, int amount);
    event TransferredByApproved(address sender, address receiver, int amount);
    event Approved(address account);
    event Disapproved(address account);

    // Direct transfer from user to user
    function transfer (int amount, address receiver) {
        if (amount < 0) throw;
        updateBalance(msg.sender, -amount);
        updateBalance(receiver, amount);
        TransferredDirectly(msg.sender, receiver, amount);
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

    function balance(address account) constant returns(int) {
        return balances[account];
    }

    function is_approved(address account) constant returns(bool) {
        return approved_accounts[account];
    }

    // IOU Token owner can whitelist an account
    function approve_account (address account) onlyOwner {
        approved_accounts[account] = true;
        Approved(account);
    }

    // IOU Token owner can unwhitelist an account
    function disapprove_account (address account) onlyOwner {
        approved_accounts[account] = false;
        Disapproved(account);
    }
}
