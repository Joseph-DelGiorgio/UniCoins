// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract UNCollaboration {
    struct CollaborationTask {
        address projectManager;
        string taskDescription;
        uint256 reward;
        bool completed;
        address collaborator;
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
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function addCollaborator(address _collaborator) public {
        require(projectManagers[msg.sender] == true, "Only project managers can add collaborators.");
        collaborators[_collaborator] = true;
    }

    function removeCollaborator(address _collaborator) public {
        require(projectManagers[msg.sender] == true, "Only project managers can remove collaborators.");
        collaborators[_collaborator] = false;
    }

   function addProjectManager(address _projectManager) public {
        require(projectManagers[msg.sender] == true, "Only project managers can add other project managers.");
        projectManagers[_projectManager] = true;
    }

    function createTask(string memory _taskDescription, uint256 _reward) public {
        require(projectManagers[msg.sender] == true, "Only project managers can create tasks.");
        tasks.push(CollaborationTask(msg.sender, _taskDescription, _reward, false, address(0)));
    }

    function assignCollaborator(uint256 taskId, address collaborator) public {
        require(collaborators[collaborator], "Collaborator address not found");
        require(tasks[taskId].projectManager == msg.sender, "Only the project manager can assign a collaborator");
        require(tasks[taskId].collaborator == address(0), "Task already has a collaborator assigned");
        tasks[taskId].collaborator = collaborator;
    }

   function completeTask(uint256 _taskId) public {
    require(collaborators[msg.sender] == true, "Only collaborators can complete tasks.");
    require(tasks[_taskId].completed == false, "This task has already been completed.");
    tasks[_taskId].completed = true;
    tasks[_taskId].collaborator = msg.sender;
    balances[msg.sender].balance += tasks[_taskId].reward;
    }

  function addBadge(string memory _badgeDescription, uint256 _hoursContributed) public {
    require(collaborators[msg.sender] == true, "Only collaborators can add badges.");
    balances[msg.sender].badges[msg.sender] = Badge(_badgeDescription, _hoursContributed);
   }

  function getBadge(address _collaborator) public view returns (string memory) {
    return balances[_collaborator].badges[_collaborator].badgeDescription;
    }
}
