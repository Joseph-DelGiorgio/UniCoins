// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract UNCollaboration is ERC20, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

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

    struct StakingPosition {
        address staker;
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
    }

    mapping(address => UNicoinBalance) private balances;
    mapping(address => bool) public collaborators;
    mapping(address => bool) public projectManagers;
    mapping(address => StakingPosition[]) public stakingPositions;

    uint256 public constant TOTAL_UNICOINS = 21000000 * 10 ** 18;
    uint256 public stakingFeePercentage = 0; // Initialize staking fee to 0%

    CollaborationTask[] public tasks;

    UNBadge public badgeContract;

    event TaskAdded(uint256 indexed taskId, address indexed projectManager, string taskDescription, uint256 reward, address collaborator);
    event TaskCompleted(uint256 indexed taskId, address indexed collaborator, uint256 reward);
    event CollaboratorAdded(address indexed collaborator);
    event ProjectManagerAdded(address indexed projectManager);
    event TokensMinted(address indexed receiver, uint256 amount);
    event StakingFeePercentageChanged(uint256 newPercentage);

    constructor(address badgeContractAddress) ERC20("UNCollaboration Coin", "UNC") {
        _mint(msg.sender, TOTAL_UNICOINS);

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
        collaboratorBalance.balance = collaboratorBalance.balance.add(task.reward);
        emit TaskCompleted(taskIndex, msg.sender, task.reward);
    }

    function awardBadge(address collaborator, uint256 tokenId, string memory badgeDescription, uint256 hoursContributed) public {
        require(projectManagers[msg.sender], "Only project managers can award badges");
        UNicoinBalance storage collaboratorBalance = balances[collaborator];
        collaboratorBalance.badges[msg.sender] = Badge(badgeDescription, hoursContributed);
        badgeContract.mint(collaborator, tokenId, hoursContributed, 0);
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
        require(totalSupply().add(amount) <= TOTAL_UNICOINS, "Minting would exceed total supply");
        _mint(receiver, amount);
        emit TokensMinted(receiver, amount);
    }

    function setStakingFeePercentage(uint256 newPercentage) public onlyOwner {
        require(newPercentage >= 0 && newPercentage <= 100, "Invalid staking fee percentage");
        stakingFeePercentage = newPercentage;
        emit StakingFeePercentageChanged(newPercentage);
    }

    function stakeTokens(uint256 amount, uint256 duration) public nonReentrant {
        require(collaborators[msg.sender], "Only collaborators can stake");
        require(amount > 0, "Stake amount must be greater than 0");
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");

        // Apply staking fee
        uint256 fee = amount.mul(stakingFeePercentage).div(100);
        uint256 stakingAmount = amount.sub(fee);

        // Transfer tokens to this contract
        transfer(address(this), stakingAmount);

        // Create the staking position
        stakingPositions[msg.sender].push(
            StakingPosition(msg.sender, stakingAmount, block.timestamp, block.timestamp.add(duration))
        );
    }

    function unstakeTokens() public nonReentrant {
        require(collaborators[msg.sender], "Only collaborators can unstake");

        StakingPosition[] storage positions = stakingPositions[msg.sender];
        require(positions.length > 0, "No staking positions found");

        // Find the most recent staking position
        StakingPosition storage lastPosition = positions[positions.length - 1];
        require(block.timestamp >= lastPosition.endTime, "Staking position still active");

        // Transfer tokens back to the caller
        transfer(msg.sender, lastPosition.amount);

        // Remove the staking position
        positions.pop();
    }

    function stakedBalance(address collaborator, uint256 timestamp) public view returns (uint256) {
        StakingPosition[] storage positions = stakingPositions[collaborator];
        uint256 balance = 0;

        for (uint256 i = 0; i < positions.length; i++) {
            StakingPosition storage position = positions[i];
            if (timestamp >= position.startTime && timestamp <= position.endTime) {
                balance = balance.add(position.amount);
            }
        }
        return balance;
    }
}

contract UNBadge is ERC721, Ownable {
    using SafeMath for uint256;

    struct BadgeData {
        uint256 hoursContributed;
        uint256 level;
    }

    mapping(uint256 => BadgeData) public badgeData;

    constructor() ERC721("UNCollaboration Badge", "UNB") {}

    function mint(address to, uint256 tokenId, uint256 hoursContributed, uint256 level) public onlyOwner {
        _mint(to, tokenId);
        badgeData[tokenId] = BadgeData(hoursContributed, level);
    }

    function getBadgeData(uint256 tokenId) public view returns (uint256 hoursContributed, uint256 level) {
        require(_exists(tokenId), "Token ID does not exist");
        return (badgeData[tokenId].hoursContributed, badgeData[tokenId].level);
    }
}
