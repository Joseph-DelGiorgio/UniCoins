import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../contexts/Web3Context';
import { Container, Table, Button, Form } from 'react-bootstrap';

function Tasks() {
  const { web3, account, contract } = useWeb3();
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const fetchTasks = async () => {
      if (contract) {
        const taskCount = await contract.methods.tasksCount().call();
        const fetchedTasks = [];
        for (let i = 0; i < taskCount; i++) {
          const task = await contract.methods.tasks(i).call();
          fetchedTasks.push(task);
        }
        setTasks(fetchedTasks);
      }
    };

    fetchTasks();
  }, [contract]);

  const handleTaskCompletion = async (taskIndex) => {
    await contract.methods.completeTask(taskIndex).send({ from: account });
    window.location.reload();
  };

  return (
    <Container>
      <h1>Tasks</h1>
      <Table striped bordered hover>
        <thead>
          <tr>
            <th>#</th>
            <th>Task Description</th>
            <th>Reward</th>
            <th>Status</th>
            <th>Action</th>
          </tr>
        </thead>
        <tbody>
          {tasks.map((task, index) => (
            <tr key={index}>
              <td>{index}</td>
              <td>{task.taskDescription}</td>
              <td>{web3.utils.fromWei(task.reward, 'ether')} UNC</td>
              <td>{task.completed ? 'Completed' : 'Pending'}</td>
              <td>
                {!task.completed && (
                  <Button variant="success" onClick={() => handleTaskCompletion(index)}>
                    Complete
                  </Button>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </Table>
    </Container>
  );
}

export default Tasks;