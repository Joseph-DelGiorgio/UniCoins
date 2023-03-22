import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../contexts/Web3Context';
import { Container, Table } from 'react-bootstrap';

function Projects() {
  const { web3, contract } = useWeb3();
  const [proposals, setProposals] = useState([]);

  useEffect(() => {
    const fetchProposals = async () => {
      if (!contract) return;

      try {
        const proposalCount = await contract.methods.nextProposalId().call();
        const fetchedProposals = await Promise.all(
          Array.from({ length: proposalCount }, (_, i) =>
            contract.methods.projectProposals(i).call()
          )
        );
        setProposals(fetchedProposals);
      } catch (error) {
        console.error('Error fetching proposals:', error);
      }
    };

    fetchProposals();
  }, [contract]);

  const renderStatus = (proposal) => {
    if (!proposal.validated) return 'Pending Validation';
    return proposal.deliverablesMet ? 'Deliverables Met' : 'Deliverables Not Met';
  };

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
              <td>{renderStatus(proposal)}</td>
            </tr>
          ))}
        </tbody>
      </Table>
    </Container>
  );
}

export default Projects;


