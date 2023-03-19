UNCollaboration Coin & Badge
This repository contains the smart contract code for the UNCollaboration Coin (UNC) and the UNCollaboration Badge (UNB). The UNCollaboration Coin is an ERC20 token used for rewarding volunteers for their contributions to various projects, while the UNCollaboration Badge is an ERC721 token awarded to volunteers as a recognition of their contributions in terms of hours.

Features

Project managers can create collaboration tasks with rewards in UNCollaboration Coins.
Volunteers can complete tasks and receive rewards in UNCollaboration Coins.
Project managers can mint new UNCollaboration Coins.
Project managers can award badges to volunteers for their contributions.
Volunteers can propose new projects by staking UNCollaboration Coins.
Project managers can validate proposed projects and update project deliverables.
Staking fee percentage can be updated by the contract owner.
Getting Started
To interact with the smart contracts, you need to have a local Ethereum development environment setup, like Truffle.

Install the dependencies: npm install
Compile the contracts: truffle compile
Deploy the contracts: truffle migrate
Interact with the contracts using Truffle console: truffle console
Contracts

UNCollaboration: The UNCollaboration contract inherits from ERC20, Ownable, and ReentrancyGuard. It contains the main functionalities for managing tasks, volunteers, project managers, and staking.
UNBadge: The UNBadge contract inherits from ERC721 and Ownable. It is responsible for minting badges and storing the data related to each badge, including hours contributed and badge level.
Events

TaskAdded: Emitted when a new task is added.
TaskCompleted: Emitted when a task is completed by a volunteer.
VolunteerAdded: Emitted when a new volunteer is added.
ProjectManagerAdded: Emitted when a new project manager is added.
TokensMinted: Emitted when new UNCollaboration Coins are minted.
StakingFeePercentageChanged: Emitted when the staking fee percentage is updated.
ProjectProposed: Emitted when a new project is proposed by a volunteer.
ProjectValidated: Emitted when a project is validated by a project manager.
ProjectDeliverablesUpdated: Emitted when the project deliverables are updated by a project manager.
Testing
To run the tests for the smart contracts, use the following command: truffle test

License
The smart contract code is licensed under the UNLICENSED license.
