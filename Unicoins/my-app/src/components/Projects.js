import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../contexts/Web3Context';
import { Container, Table, Button, Form } from 'react-bootstrap';

function Projects() {
  const { web3, account, contract } = useWeb3();
  const [proposals, setProposals] = useState([]);

  useEffect(() => {
    const fetchProposals = async () => {
      if (contract) {
        try {
          const proposalCount = await contract.methods.nextProposalId().call();
          const fetchedProposals = [];
          for (let i = 0; i < proposalCount; i++) {
            const proposal = await contract.methods.projectProposals(i).call();
            fetchedProposals.push(proposal);
          }
          setProposals(fetchedProposals);
        } catch (error) {
          console.error('Error fetching proposals:', error);
        }
      }
    };
  
    fetchProposals();
  }, [contract]);
  

  return (
    <Container>
      <h1>Projects</h1>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>#</th>
            <th>Project Description</th>
            <th>Staked Amount</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          {proposals.map((proposal, index) => (
            <tr key={index}>
              <td>{index}</td>
              <td>{proposal.projectDescription}</td>
              <td>{web3.utils.fromWei(proposal.stakedAmount, 'ether')} UNC</td>
              <td>
                {proposal.validated
                  ? proposal.deliverablesMet
                    ? 'Deliverables Met'
                    : 'Deliverables Not Met'
                  : 'Pending Validation'}
              </td>
            </tr>
          ))}
        </tbody>
      </Table>
    </Container>
  );
}

export default Projects;

