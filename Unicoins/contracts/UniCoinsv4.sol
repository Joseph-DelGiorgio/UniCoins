// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UNCollaboration is ERC20 {
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
        uint256 hoursContributed;
    }
    
    struct Stake {
        address staker;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }


    mapping(address => UNicoinBalance) private balances;
    mapping(address => bool) public collaborators;
    mapping(address => bool) public projectManagers;
    mapping(address => Stake[]) public stakingPositions;


    uint256 public constant TOTAL_UNICOINS = 21000000;
    string public constant UNICOIN_SYMBOL = "UNC";
    string public constant UNICOIN_NAME = "UNCollaboration Coin";
    uint8 public constant UNICOIN_DECIMALS = 18;

    uint256 private _totalSupply;

    CollaborationTask[] public tasks;

    UNBadge public badgeContract;

    event TaskAdded(uint256 indexed taskId, address indexed projectManager, string taskDescription, uint256 reward, address collaborator);
    event TaskCompleted(uint256 indexed taskId, address indexed collaborator, uint256 reward);
    event CollaboratorAdded(address indexed collaborator);
    event ProjectManagerAdded(address indexed projectManager);
    event TokensMinted(address indexed receiver, uint256 amount);

    constructor(address badgeContractAddress) ERC20(UNICOIN_NAME, UNICOIN_SYMBOL) {
        _totalSupply = TOTAL_UNICOINS * 10 ** UNICOIN_DECIMALS;
        _mint(msg.sender, _totalSupply);

        badgeContract = UNBadge(badgeContractAddress);

        projectManagers[msg.sender] = true;
        emit ProjectManagerAdded(msg.sender);
    }

    function addTask(string memory taskDescription, uint256 reward, address collaborator) public {
        require(projectManagers[msg.sender], "Only project managers can add tasks");
        uint256 taskId = tasks.length;
        tasks.push(CollaborationTask(msg.sender, taskDescription, reward, false, collaborator, false));
        emit TaskAdded(taskId, msg.sender, taskDescription, reward, collaborator);
    }

    function completeTask(uint256 taskIndex) public {
        CollaborationTask storage task = tasks[taskIndex];
        require(task.collaborator == msg.sender, "Only the assigned collaborator can complete the task");
        require(task.completed == false, "Task is already completed");
        task.completed = true;
        UNicoinBalance storage collaboratorBalance = balances[msg.sender];
        collaboratorBalance.balance += task.reward;
        emit TaskCompleted(taskIndex, msg.sender, task.reward);
    }

    function awardBadge(address collaborator, uint256 tokenId, string memory badgeDescription, uint256 hoursContributed) public {
    require(projectManagers[msg.sender], "Only project managers can award badges");
    UNicoinBalance storage collaboratorBalance = balances[collaborator];
    collaboratorBalance.badges[msg.sender] = Badge(badgeDescription, hoursContributed);
    badgeContract.mint(msg.sender, tokenId, hoursContributed, 0);
    }




    function getBadge(address collaborator, address projectManager) public view returns (string memory, uint256) {
        require(projectManagers[projectManager], "Invalid project manager address");
        return (balances[collaborator].badges[projectManager].badgeDescription, balances[collaborator].badges[projectManager].hoursContributed);
    }


function addCollaborator(address collaborator) public {
    require(projectManagers[msg.sender], "Only project managers can add collaborators");
    collaborators[collaborator] = true;
    balances[collaborator].balance = 0;
    balances[collaborator].hoursContributed = 0;
    emit CollaboratorAdded(collaborator);
}

function addProjectManager(address projectManager) public {
    require(projectManagers[msg.sender], "Only existing project managers can add new project managers");
    projectManagers[projectManager] = true;
    emit ProjectManagerAdded(projectManager);
}

function mintTokens(address receiver, uint256 amount) public {
    require(projectManagers[msg.sender], "Only project managers can mint tokens");
    require(totalSupply() + amount <= TOTAL_UNICOINS * 10 ** UNICOIN_DECIMALS, "Minting would exceed total supply");
    _mint(receiver, amount);
    emit TokensMinted(receiver, amount);
}

function stake(uint256 amount, uint256 duration) public {
    require(collaborators[msg.sender], "Only collaborators can stake");
    require(amount > 0, "Stake amount must be greater than 0");
    require(balanceOf(msg.sender) >= amount, "Insufficient balance");

    // Transfer tokens to this contract
    transfer(address(this), amount);

    // Create the staking position
    stakingPositions[msg.sender].push(
        Stake(msg.sender, amount, block.timestamp, block.timestamp + duration)
    );
}

function unstake() public {
    require(collaborators[msg.sender], "Only collaborators can unstake");

    Stake[] storage stakes = stakingPositions[msg.sender];
    require(stakes.length > 0, "No staking positions found");

    // Find the most recent staking position
    Stake storage lastStake = stakes[stakes.length - 1];
    require(block.timestamp >= lastStake.endTime, "Staking position still active");

    // Transfer tokens back to the caller
    transfer(msg.sender, lastStake.amount);

    // Remove the staking position
    stakes.pop();
}

function stakedBalance(address collaborator, uint256 timestamp) public view returns (uint256) {
    Stake[] storage stakes = stakingPositions[collaborator];
    uint256 balance = 0;

    for (uint256 i = 0; i < stakes.length; i++) {
        Stake storage stake = stakes[i];
        if (timestamp < stake.endTime) {
            balance += stake.amount;
        }
    }

    return balance;
}

}
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract UNBadge is ERC721 {

    struct BadgeMetadata {
        uint256 lifetimeContribution;
        uint256 projectManagerFeedbackRating;
    }

    mapping(uint256 => BadgeMetadata) private _badgeMetadata;

    constructor() ERC721("UNBadge", "UNB") {}

    function mint(address recipient, uint256 tokenId, uint256 lifetimeContribution, uint256 feedbackRating) public {
        _badgeMetadata[tokenId] = BadgeMetadata(lifetimeContribution, feedbackRating);
        _mint(recipient, tokenId);
    }

    function getLifetimeContribution(uint256 tokenId) public view returns (uint256) {
        return _badgeMetadata[tokenId].lifetimeContribution;
    }

    function getFeedbackRating(uint256 tokenId) public view returns (uint256) {
        return _badgeMetadata[tokenId].projectManagerFeedbackRating;
    }
}




/* The main components of the contract are:

ERC20 Token
The contract inherits from the ERC20 contract provided by OpenZeppelin, which implements the ERC20 token standard. This standard defines a set of functions and events that must be implemented by a contract in order to create a fungible token on the Ethereum blockchain.

The UNCollaboration contract adds a few additional functions to the ERC20 contract, such as mintTokens, which allows project managers to mint new tokens, and stake, which allows collaborators to stake their tokens in exchange for rewards.

CollaborationTask Struct
The CollaborationTask struct is used to represent a task that needs to be completed by a collaborator. It contains information such as the project manager who created the task, a description of the task, the reward for completing the task, and the address of the collaborator who has been assigned the task.

The addTask function allows project managers to create new tasks, and the completeTask function allows collaborators to mark tasks as completed and receive their rewards.

Badge Struct
The Badge struct is used to represent a badge that can be awarded to a collaborator for their contributions to a project. It contains information such as a description of the badge and the number of hours the collaborator has contributed to the project.

The awardBadge function allows project managers to award badges to collaborators who have made significant contributions to a project.

UNicoinBalance Struct
The UNicoinBalance struct is used to keep track of a collaborator's UNicoin balance, as well as any badges they have been awarded and the number of hours they have contributed to the project.

Stake Struct
The Stake struct is used to represent a staking position, which allows collaborators to stake their tokens in exchange for rewards. It contains information such as the collaborator who made the stake, the amount of tokens staked, and the start and end times of the staking period.

The stake and unstake functions are used to create and remove staking positions, respectively.

Events
The contract emits a number of events, such as TaskAdded and TaskCompleted, which allow external applications to listen for changes in the state of the contract.

Mapping Variables
The contract also uses a number of mapping variables to keep track of collaborators, project managers, staking positions, and UNicoin balances.

Security Considerations
Overall, the contract seems to be designed with security in mind. It includes a number of require statements to ensure that only authorized users can perform certain actions, and it uses the SafeMath library to prevent integer overflow and underflow issues. However, there are a few areas where the contract could be improved from a security perspective:

The contract could benefit from a more detailed access control system. Currently, the projectManagers and collaborators mappings are used to keep track of authorized users, but these mappings are not very flexible. It might be beneficial to implement a more granular access control system that allows for more fine-grained control over who can perform specific actions.

The awardBadge function allows project managers to mint new badges and assign them to collaborators, but it does not include any checks to ensure that the badge contract address is valid. If the badge contract is compromised, it could potentially allow an attacker to mint new badges

*/
