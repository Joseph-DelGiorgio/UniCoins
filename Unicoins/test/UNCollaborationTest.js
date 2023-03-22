const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UNCollaboration", function () {
  let UNBadge, unBadge, UNCollaboration, unCollaboration, owner, addr1, addr2;

  beforeEach(async () => {
    UNBadge = await ethers.getContractFactory("UNBadge");
    unBadge = await UNBadge.deploy();
    await unBadge.deployed();

    UNCollaboration = await ethers.getContractFactory("UNCollaboration");
    unCollaboration = await UNCollaboration.deploy(unBadge.address);
    await unCollaboration.deployed();

    [owner, addr1, addr2] = await ethers.getSigners();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await unCollaboration.owner()).to.equal(owner.address);
    });

    it("Should set the right UNBadge contract address", async function () {
      expect(await unCollaboration.badgeContract()).to.equal(unBadge.address);
    });

    it("Should mint the correct amount of tokens to the owner", async function () {
      const totalSupply = await unCollaboration.totalSupply();
      expect(await unCollaboration.balanceOf(owner.address)).to.equal(totalSupply);
    });
  });

  describe("Project Manager and Volunteer Management", function () {
    it("Should add a project manager", async function () {
      await unCollaboration.addProjectManager(addr1.address);
      expect(await unCollaboration.projectManagers(addr1.address)).to.equal(true);
    });

    it("Should add a volunteer", async function () {
      await unCollaboration.addVolunteer(addr1.address);
      expect(await unCollaboration.volunteers(addr1.address)).to.equal(true);
    });
  });

  describe("Tasks", function () {
    beforeEach(async () => {
      await unCollaboration.addProjectManager(addr1.address);
      await unCollaboration.addVolunteer(addr2.address);
    });

    it("Should add a task", async function () {
      const taskDescription = "Sample Task";
      const reward = 100;

      await unCollaboration.connect(addr1).addTask(taskDescription, reward, addr2.address);

      const task = await unCollaboration.tasks(0);
      expect(task.projectManager).to.equal(addr1.address);
      expect(task.taskDescription).to.equal(taskDescription);
      expect(task.reward).to.equal(reward);
      expect(task.completed).to.equal(false);
      expect(task.volunteer).to.equal(addr2.address);
    });

    it("Should complete a task", async function () {
      const taskDescription = "Sample Task";
      const reward = 100;

      await unCollaboration.connect(addr1).addTask(taskDescription, reward, addr2.address);
      await unCollaboration.connect(addr2).completeTask(0);

      const task = await unCollaboration.tasks(0);
      expect(task.completed).to.equal(true);
    });
  });

  // Add more test cases for other functionalities as needed
});

/*
npm install --save-dev chai
*/
