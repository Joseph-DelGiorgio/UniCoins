// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./UNBadge.sol";

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

    mapping(address => UNicoinBalance) private balances;

    mapping(address => bool) public collaborators;
    mapping(address => bool) public projectManagers;

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
        badgeContract.mint(msg.sender, tokenId, collaboratorBalance.hoursContributed, new string[](0), new address[](0), 0);
    }

    function getBadge(address collaborator, address projectManager) public view returns (string memory, uint256) {
    require(projectManagers[projectManager], "Invalid project manager address");
    return (balances[collaborator].badges[projectManager].badgeDescription, balances[collaborator].badges[projectManager].hoursContributed);
    }



function addCollaborator(address collaborator) public {
    require(projectManagers[msg.sender], "Only project managers can add collaborators");
    require(!collaborators[collaborator], "Collaborator is already added");
    collaborators[collaborator] = true;
    balances[collaborator].balance = 0;
    balances[collaborator].hoursContributed = 0;
    emit CollaboratorAdded(collaborator);
}

function addProjectManager(address projectManager) public {
    require(projectManagers[msg.sender], "Only project managers can add project managers");
    require(!projectManagers[projectManager], "Project manager is already added");
    projectManagers[projectManager] = true;
    emit ProjectManagerAdded(projectManager);
}

function mint(address receiver, uint256 amount) public {
    require(projectManagers[msg.sender], "Only project managers can mint tokens");
    require(totalSupply() + amount <= _totalSupply, "Total supply exceeded");
    _mint(receiver, amount);
    emit TokensMinted(receiver, amount);
}

function balanceOf(address account) public view override returns (uint256) {
    return balances[account].balance;
}

function hoursContributed(address account) public view returns (uint256) {
    return balances[account].hoursContributed;
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

CollaborationTask struct to represent a task that can be assigned to a collaborator and completed for a reward.
Badge struct to represent a badge that can be awarded to a collaborator for their contributions.
UNicoinBalance struct to represent a balance of UNCoins for each collaborator.
balances mapping to store the UNicoinBalance for each collaborator.
tasks array to store all tasks created by project managers.
collaborators mapping to store whether an address is a collaborator or not.
projectManagers mapping to store whether an address is a project manager or not.
badgeContract address to store the address of the UNBadge contract used to mint badges.
addTask function to allow project managers to add tasks.
completeTask function to allow collaborators to complete tasks and receive a reward.
awardBadge function to allow project managers to award badges to collaborators for their contributions.
addCollaborator function to allow project managers to add collaborators.
addProjectManager function to allow project managers to add other project managers.
mint function to allow project managers to mint new UNCoins.
balanceOf function to allow users to check their UNCoin balance.
hoursContributed function to allow users to check their total hours contributed to tasks.
getBadge function to allow users to get information about a badge awarded to them by a specific project manager.

*/
