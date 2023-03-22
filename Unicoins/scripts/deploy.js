const hre = require("hardhat");

async function main() {
  // Deploy UNBadge contract
  const UNBadge = await hre.ethers.getContractFactory("UNBadge");
  const unBadge = await UNBadge.deploy();
  await unBadge.deployed();

  console.log(`UNBadge deployed to ${unBadge.address}`);

  // Deploy UNCollaboration contract
  const UNCollaboration = await hre.ethers.getContractFactory("UNCollaboration");
  const unCollaboration = await UNCollaboration.deploy(unBadge.address);
  await unCollaboration.deployed();

  console.log(`UNCollaboration deployed to ${unCollaboration.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

/* 
npm install --save-dev @openzeppelin/contracts
npm install --save-dev ethers
*/
