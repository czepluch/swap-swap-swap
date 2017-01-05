pragma solidity ^0.4.0;

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
        if (amount > 0 && new_balance < old_balance) {
            throw;
        }
        if (amount < 0 && new_balance > old_balance) {
            throw;
        }
        balances[account] += amount;
    }

    // IOU Token owner can whitelist sc
    function approve_swap_contract (address swap_contract_address) onlyOwner {
        approved_accounts[swap_contract_address] = true;
        Approved(swap_contract_address);
    }

    // IOU Token owner can blacklist sc
    function block_swap_contract (address swap_contract_address) onlyOwner {
        approved_accounts[swap_contract_address] = false;
        Disapproved(swap_contract_address);
    }
}
