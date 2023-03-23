import { Web3Provider } from './contexts/Web3Context';
import Navbar from './components/Navbar';
import Tasks from './components/Tasks';
import Projects from './components/Projects';
//import './App.css';
import React, { useState, useEffect } from 'react';
import Web3 from 'web3';
import UNCollaborationABI from './UNCollaborationABI.json';
import UNBadgeABI from './UNBadgeABI.json';
import './styles.css';

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
      // Consider displaying an alert or notification to the user about the missing Web3 provider.
     }
   };


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

  const addTask = async (taskDescription, reward, volunteer) => {
    if (UNCollaborationContract) {
      await UNCollaborationContract.methods
        .addTask(taskDescription, reward, volunteer)
        .send({ from: account });
    }
  };

  const completeTask = async (taskIndex) => {
    if (UNCollaborationContract) {
      await UNCollaborationContract.methods
        .completeTask(taskIndex)
        .send({ from: account });
    }
  };

  const awardBadge = async (volunteer, tokenId, badgeDescription, hoursContributed) => {
    if (UNBadgeContract) {
      await UNBadgeContract.methods
        .awardBadge(volunteer, tokenId, badgeDescription, hoursContributed)
        .send({ from: account });
    }
  };

  return (
    <Web3Provider value={{ web3, account, UNCollaborationContract, UNBadgeContract }}>
      <div className="App">
        <Navbar />
        <Tasks tasks={tasks} addTask={addTask} completeTask={completeTask} />
        <Projects awardBadge={awardBadge} />
      </div>
    </Web3Provider>
  );
};

export default App;

