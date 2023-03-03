// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UNCollaboration {
    struct CollaborationTask {
        address projectManager;
        string taskDescription;
        uint256 reward;
        bool completed;
        address collaborator;
        bool authorized;
    }
    struct Badge {
        string badgeDescription;
        uint256 hoursContributed;
    }
    struct UNicoinBalance {
        uint256 balance;
        mapping(address => Badge) badges;
    }

    mapping(address => UNicoinBalance) public balances;
    mapping(address => bool) public collaborators;
    mapping(address => bool) public projectManagers;

    uint256 public constant TOTAL_UNICOINS = 21000000;
    string public constant UNICOIN_SYMBOL = "UNC";
    string public constant UNICOIN_NAME = "UNCollaboration Coin";
    uint8 public constant UNICOIN_DECIMALS = 18;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    CollaborationTask[] public tasks;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        _totalSupply = TOTAL_UNICOINS * 10 ** UNICOIN_DECIMALS;
        _balances[msg.sender] = _totalSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
        // Add the deployer address to the projectManagers mapping
        projectManagers[msg.sender] = true;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
    require(sender != address(0), "ERC20: transfer from the zero address");
    require(recipient != address(0), "ERC20: transfer to the zero address");
    uint256 senderBalance = _balances[sender];
require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
_balances[sender] = senderBalance - amount;

// Check if the recipient is a collaborator and the task is authorized before transferring UNicoins
if (collaborators[recipient]) {
    CollaborationTask storage task = tasks[tasks.length - 1];
    require(task.collaborator == recipient, "ERC20: recipient is not the collaborator for the task");
    require(task.authorized == true, "ERC20: task is not authorized");
    UNicoinBalance storage recipientBalance = balances[recipient];
    recipientBalance.balance += task.reward;
    emit Transfer(sender, recipient, task.reward);
} else {
    _balances[recipient] += amount;
    emit Transfer(sender, recipient, amount);
}
}
function _approve(address owner, address spender, uint256 amount) private {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
}

function addTask(string memory taskDescription, uint256 reward, address collaborator) public {
    require(projectManagers[msg.sender], "Only project managers can add tasks");
    tasks.push(CollaborationTask(msg.sender, taskDescription, reward, false, collaborator, false));
}

  /*function assignCollaborator(uint256 taskId, address collaborator) public {
        require(collaborators[collaborator], "Collaborator address not found");
        require(tasks[taskId].projectManager == msg.sender, "Only the project manager can assign a collaborator");
        require(tasks[taskId].collaborator == address(0), "Task already has a collaborator assigned");
        tasks[taskId].collaborator = collaborator;
    }
    */

function completeTask(uint256 taskIndex) public {
    CollaborationTask storage task = tasks[taskIndex];
    require(task.collaborator == msg.sender, "Only the assigned collaborator can complete the task");
    require(task.completed == false, "Task is already completed");
    UNicoinBalance storage collaboratorBalance = balances[msg.sender];
    collaboratorBalance.badges[msg.sender].hoursContributed += 1;
    task.completed = true;
}

function addCollaborator(address collaborator) public {
    require(projectManagers[msg.sender], "Only project managers can add collaborators");
    collaborators[collaborator] = true;
}

function getBadge(address collaborator) public view returns (Badge memory) {
    require(collaborators[collaborator], "Address is not a collaborator");
    return balances[collaborator].badges[collaborator];
}
}
