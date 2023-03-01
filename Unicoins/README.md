The UNCollaboration smart contract is built using the Solidity programming language and is designed to enable decentralized collaboration between project managers and collaborators. The smart contract features a custom ERC20 token named "UNCollaboration Coin" (UNC), which can be used to reward collaborators for completing tasks.

The main authors are Niklas Forsström, Eleonora Gatti, Samuel Lawson, Marc Liberati, and Pipin Tasdyata. The designers are Akash K P, Camile Yeung, Mariana Montes de Oca, Tamish Dahiya, and Harshvardhan Singh. The lead editor is Ruth Blackshaw. The UNicoins team members who advised on the project are Simon Bettighofer, Amelia Craig, Michaela Markova, and Klas Moldeus.

The smart contract includes several key features, including:

A CollaborationTask struct that includes information about each task, such as the project manager, task description, reward, start and end times, completion status, and assigned collaborator.
A Badge struct that contains a description of a collaborator's badge and the number of hours they have contributed.
A UNicoinBalance struct that contains a collaborator's UNCollaboration Coin balance and a mapping of the badges they have earned.
Several mappings that keep track of collaborator and project manager addresses, as well as task and UNCollaboration Coin balances.
Functions to create a new task, assign a collaborator to a task, complete a task, and add a collaborator to a project.
An ERC20-compliant token that can be used to reward collaborators for completing tasks.
The smart contract is deployed using the Ethereum blockchain and can be interacted with using any Ethereum wallet that supports ERC20 tokens.

The UNCollaboration smart contract is designed to facilitate collaboration between individuals and organizations by using blockchain technology to manage tasks, rewards, and badges. The contract is written in Solidity, the programming language used to develop smart contracts on the Ethereum blockchain.

The contract has several functions to manage the UNicoins, the native currency of the UNCollaboration platform. UNicoins are ERC-20 tokens that can be transferred between accounts, and are used to reward collaborators for completing tasks. The total supply of UNicoins is set to 21 million, and the contract is designed to handle up to 18 decimal places for precision.

In addition to managing UNicoins, the contract also manages tasks and collaborators. Tasks are created by project managers, and can be assigned to collaborators for completion. Collaborators are added to the platform by project managers, and can be assigned to tasks once they are added. Collaborators who complete tasks are rewarded with UNicoins, which are added to their account balance.

The contract also includes a badge system, which allows project managers to recognize and reward collaborators who contribute to their projects. Project managers can add badges to a collaborator's account, which can be used to display their achievements and contributions on the platform.

The UNCollaboration smart contract was developed by a team of blockchain developers, designers, and advisors, and is intended to be used by individuals and organizations looking to collaborate on projects and initiatives. By using blockchain technology to manage tasks, rewards, and badges, the platform aims to create a more transparent and decentralized system for collaboration.