import React, { createContext, useContext, useState, useEffect } from 'react';
import Web3 from 'web3';
import UNCollaborationABI from '../abis/UNCollaboration.json';

const Web3Context = createContext();

export function useWeb3() {
  return useContext(Web3Context);
}

export function Web3Provider({ children }) {
  const [web3, setWeb3] = useState();
  const [account, setAccount] = useState();
  const [contract, setContract] = useState();

  useEffect(() => {
    const initWeb3 = async () => {
      if (window.ethereum) {
        const web3Instance = new Web3(window.ethereum);
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        setWeb3(web3Instance);
      } else {
        alert('Please install MetaMask to use this app.');
      }
    };
    initWeb3();
  }, []);

  useEffect(() => {
    const loadBlockchainData = async () => {
      if (!web3) return;

      const accounts = await web3.eth.getAccounts();
      setAccount(accounts[0]);

      const networkId = await web3.eth.net.getId();
      const contractData = UNCollaborationABI.networks[networkId];

      if (contractData) {
        const contractInstance = new web3.eth.Contract(UNCollaborationABI.abi, contractData.address);
        setContract(contractInstance);
      } else {
        alert('UNCollaboration contract not deployed on the connected network.');
      }
    };

    loadBlockchainData();
  }, [web3]);

  const value = {
    web3,
    account,
    contract,
  };

  return <Web3Context.Provider value={value}>{children}</Web3Context.Provider>;
}

