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
        address volunteer;
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

    struct ProjectProposal {
        address proposer;
        string projectDescription;
        uint256 stakedAmount;
        bool validated;
        bool deliverablesMet;
    }

    mapping(address => UNicoinBalance) private balances;
    mapping(address => bool) public volunteers;
    mapping(address => bool) public projectManagers;
    mapping(address => StakingPosition[]) public stakingPositions;
    mapping(uint256 => ProjectProposal) public projectProposals;

    uint256 public constant TOTAL_UNICOINS = 21000000 * 10 ** 18;
    uint256 public stakingFeePercentage = 0; // Initialize staking fee to 0%

    uint256 public nextProposalId = 0;

    CollaborationTask[] public tasks;

    UNBadge public badgeContract;

    event TaskAdded(uint256 indexed taskId, address indexed projectManager, string taskDescription, uint256 reward, address volunteer);
    event TaskCompleted(uint256 indexed taskId, address indexed volunteer, uint256 reward);
    event VolunteerAdded(address indexed volunteer);
    event ProjectManagerAdded(address indexed projectManager);
    event TokensMinted(address indexed receiver, uint256 amount);
    event StakingFeePercentageChanged(uint256 newPercentage);
    event ProjectProposalAdded(uint256 indexed proposalId, address indexed proposer, string projectDescription, uint256 stakedAmount);
    event ProjectProposalValidated(uint256 indexed proposalId, bool validated);
    event ProjectDeliverablesUpdated(uint256 indexed proposalId, bool deliverablesMet);
    event ProjectStakeForfeited(uint256 indexed proposalId, address indexed proposer, uint256 stakedAmount);

    constructor(address badgeContractAddress) ERC20("UNCollaboration Coin", "UNC") {
        _mint(msg.sender, TOTAL_UNICOINS);

        badgeContract = UNBadge(badgeContractAddress);

        projectManagers[msg.sender] = true;
        emit ProjectManagerAdded(msg.sender);
    }

    function addTask(string memory taskDescription, uint256 reward, address volunteer) public {
        require(projectManagers[msg.sender], "Only project managers can add tasks");
        uint256 taskId = tasks.length;
        tasks.push(CollaborationTask(msg.sender, taskDescription, reward, false, volunteer, false));
        emit TaskAdded(taskId, msg.sender, taskDescription, reward, volunteer);
    }

    function completeTask(uint256 taskIndex) public {
        CollaborationTask storage task = tasks[taskIndex];
        require(task.volunteer == msg.sender, "Only the assigned volunteer can complete the task");
        require(task.completed == false, "Task is already completed");
        task.completed = true;
        UNicoinBalance storage volunteerBalance = balances[msg.sender];
        volunteerBalance.balance = volunteerBalance.balance.add(task.reward);
        emit TaskCompleted(taskIndex, msg.sender, task.reward);
    }

     function awardBadge(address volunteer, uint256 tokenId, string memory badgeDescription, uint256 hoursContributed) public {
        require(projectManagers[msg.sender], "Only project managers can award badges");
        UNicoinBalance storage volunteerBalance = balances[volunteer];
        volunteerBalance.badges[msg.sender] = Badge(badgeDescription, hoursContributed);
        badgeContract.mint(volunteer, tokenId, hoursContributed, 0);
    }

    function getBadge(address volunteer, address projectManager) public view returns (string memory, uint256) {
        require(projectManagers[projectManager], "Invalid project manager address");
        return (balances[volunteer].badges[projectManager].badgeDescription, balances[volunteer].badges[projectManager].hoursContributed);
    }

    function addVolunteer(address volunteer) public {
        require(projectManagers[msg.sender], "Only project managers can add volunteers");
        volunteers[volunteer] = true;
        balances[volunteer].balance = 0;
        balances[volunteer].hoursContributed = 0;
        emit VolunteerAdded(volunteer);
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

  function proposeProject(string memory projectDescription, uint256 stakingAmount) public nonReentrant {
    require(volunteers[msg.sender], "Only volunteers can propose projects");
    require(stakingAmount > 0, "Staking amount must be greater than 0");
    require(balanceOf(msg.sender) >= stakingAmount, "Insufficient balance");

    // Transfer tokens to this contract
    transfer(address(this), stakingAmount);

    // Create the project proposal
    uint256 proposalId = nextProposalId;
    projectProposals[proposalId] = ProjectProposal(msg.sender, projectDescription, stakingAmount, false, false);
    nextProposalId++;

    emit ProjectProposalAdded(proposalId, msg.sender, projectDescription, stakingAmount);
  }

  function validateProposal(uint256 proposalId, bool isValid) public {
    require(projectManagers[msg.sender], "Only project managers can validate proposals");
    ProjectProposal storage proposal = projectProposals[proposalId];
    require(proposal.validated == false, "Proposal is already validated");

    proposal.validated = isValid;

    emit ProjectProposalValidated(proposalId, isValid);
  }

  function updateProjectDeliverables(uint256 proposalId, bool deliverablesMet) public {
    require(projectManagers[msg.sender], "Only project managers can update project deliverables");
    ProjectProposal storage proposal = projectProposals[proposalId];
    require(proposal.validated, "Proposal must be validated before updating deliverables");
    proposal.deliverablesMet = deliverablesMet;
        emit ProjectDeliverablesUpdated(proposalId, deliverablesMet);

    if (!deliverablesMet) {
        // Forfeit staked tokens
        _burn(address(this), proposal.stakedAmount);
        emit ProjectStakeForfeited(proposalId, proposal.proposer, proposal.stakedAmount);
    } else {
        // Return staked tokens to the proposer
        transfer(proposal.proposer, proposal.stakedAmount);
    }
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
