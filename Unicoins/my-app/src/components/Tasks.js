import React, { useState, useEffect } from 'react';
import { useWeb3 } from '../contexts/Web3Context';
import { Container, Table, Button } from 'react-bootstrap';

function Tasks() {
  const { web3, account, contract } = useWeb3();
  const [tasks, setTasks] = useState([]);

  useEffect(() => {
    const fetchTasks = async () => {
      if (!contract) return;

      try {
        const taskCount = await contract.methods.tasksCount().call();
        const fetchedTasks = await Promise.all(
          Array.from({ length: taskCount }, (_, i) =>
            contract.methods.tasks(i).call()
          )
        );
        setTasks(fetchedTasks);
      } catch (error) {
        console.error('Error fetching tasks:', error);
      }
    };

    fetchTasks();
  }, [contract]);

  const handleTaskCompletion = async (taskIndex) => {
    try {
      await contract.methods.completeTask(taskIndex).send({ from: account });
      setTasks(
        tasks.map((task, index) =>
          index === taskIndex ? { ...task, completed: true } : task
        )
      );
    } catch (error) {
      console.error('Error completing task:', error);
    }
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
