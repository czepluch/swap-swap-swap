pragma solidity ^0.4.0;

contract owned {
    address owner;
    function owned() {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) onlyowner {
        owner = newOwner;
    }

    modifier onlyowner() {
        if (msg.sender == owner) _ ;
    }
}

contract Iou_token is owned {
    mapping (address => bool) public valid_swap_contracts;
    mapping (address => int) public balances;

    event Directly_transferred(address sender, address receiver, uint amount);
    event Transferred_by_swap_contract(address sender, address receiver, int amount);
    event Approved_swap_contract(address smart_contract);
    event Blocked_swap_contract(address smart_contract);

    string public name;

    // Initializing the Token
    function Iou_token (string _name) {
        name = _name;
    }

    // Direct transfer from user to user
    function transfer (uint amount, address receiver) {
        //TODO check for overflow
        balances[msg.sender] -= int(amount);
        balances[receiver] += int(amount);
        Directly_transferred(msg.sender, receiver, amount);
    }

    // Transer initiated by a SC
    function transfer_from_sc (int amount, address sender, address receiver) {
        if(valid_swap_contracts[msg.sender] == true) {
            balances[msg.sender] -= amount;
            balances[receiver] += amount;
            Transferred_by_swap_contract(sender, receiver, amount);
        }
        else throw;
    }

    // IOU Token owner can whitelist sc
    function approve_swap_contract (address swap_contract_address) onlyowner {
        valid_swap_contracts[swap_contract_address] = true;
        Approved_swap_contract(swap_contract_address);
    }

    // IOU Token owner can blacklist sc
    function block_swap_contract (address swap_contract_address) onlyowner {
        valid_swap_contracts[swap_contract_address] = false;
        Blocked_swap_contract(swap_contract_address);
    }
}
