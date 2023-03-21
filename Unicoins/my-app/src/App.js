import { Web3Provider } from './contexts/Web3Context';
import Navbar from './components/Navbar';
import Tasks from './components/Tasks';
import Projects from './components/Projects';
import './App.css';
import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import UNCollaborationABI from './UNCollaborationABI.json';
import UNBadgeABI from './UNBadgeABI.json';

const UNCollaborationAddress = 'REPLACE_WITH_UNCOLLABORATION_CONTRACT_ADDRESS';
const UNBadgeAddress = 'REPLACE_WITH_UNBADGE_CONTRACT_ADDRESS';

const App = () => {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [UNCollaborationContract, setUNCollaborationContract] = useState(null);
  const [UNBadgeContract, setUNBadgeContract] = useState(null);
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        setWeb3(web3Instance);
      } else {
        console.log('Please install MetaMask!');
      }
    };

    initWeb3();
  }, []);

  useEffect(() => {
    const initContracts = async () => {
      if (web3) {
        const accounts = await web3.eth.getAccounts();
        setAccount(accounts[0]);

        const UNCollaboration = new web3.eth.Contract(UNCollaborationABI, UNCollaborationAddress);
        setUNCollaborationContract(UNCollaboration);

        const UNBadge = new web3.eth.Contract(UNBadgeABI, UNBadgeAddress);
        setUNBadgeContract(UNBadge);
      }
    };

    initContracts();
  }, [web3]);

  useEffect(() => {
    const fetchTasks = async () => {
      if (UNCollaborationContract) {
        const taskCount = await UNCollaborationContract.methods.getTaskCount().call();
        const fetchedTasks = [];

        for (let i = 0; i < taskCount; i++) {
          const task = await UNCollaborationContract.methods.tasks(i).call();
          fetchedTasks.push(task);
        }

        setTasks(fetchedTasks);
      }
    };

    fetchTasks();
  }, [UNCollaborationContract]);

  // Add other functions like addTask, completeTask, awardBadge, etc., using the smart contract's methods.

  return (
    <div>
      <h1>UNCollaboration Platform</h1>
      <h2>Tasks</h2>
      <ul>
        {tasks.map((task, index) => (
          <li key={index}>
            {task.taskDescription} - Reward: {task.reward} UNCs - Status: {task.completed ? 'Completed' : 'Incomplete'}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default App;
