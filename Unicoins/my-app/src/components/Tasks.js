import React, { useState } from 'react';
import Task from './Task';
import Modal from 'react-modal';

const customStyles = {
  content: {
    top: '50%',
    left: '50%',
    right: 'auto',
    bottom: 'auto',
    marginRight: '-50%',
    transform: 'translate(-50%, -50%)',
  },
};

Modal.setAppElement('#root');

const Tasks = ({ tasks, addTask, completeTask }) => {
  const [modalIsOpen, setModalIsOpen] = useState(false);
  const [taskDescription, setTaskDescription] = useState('');
  const [reward, setReward] = useState('');
  const [volunteer, setVolunteer] = useState('');

  const openModal = () => {
    setModalIsOpen(true);
  };

  const closeModal = () => {
    setModalIsOpen(false);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    await addTask(taskDescription, reward, volunteer);
    setTaskDescription('');
    setReward('');
    setVolunteer('');
    closeModal();
  };

  return (
    <div className="container">
      <h2>Tasks</h2>
      <button onClick={openModal} className="btn btn-primary">
        Create Task
      </button>
      <Modal isOpen={modalIsOpen} onRequestClose={closeModal} style={customStyles} contentLabel="Task Modal">
        <h3>Create Task</h3>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label htmlFor="taskDescription">Task Description:</label>
            <input
              type="text"
              id="taskDescription"
              className="form-control"
              value={taskDescription}
              onChange={(e) => setTaskDescription(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="reward">Reward:</label>
            <input
              type="number"
              id="reward"
              className="form-control"
              value={reward}
              onChange={(e) => setReward(e.target.value)}
              required
            />
          </div>
          <div className="form-group">
            <label htmlFor="volunteer">Volunteer Address:</label>
            <input
              type="text"
              id="volunteer"
              className="form-control"
              value={volunteer}
              onChange={(e) => setVolunteer(e.target.value)}
              required
            />
          </div>
          <button type="submit" className="btn btn-success">
            Submit
          </button>
          <button onClick={closeModal} className="btn btn-danger" style={{ marginLeft: '10px' }}>
            Cancel
          </button>
        </form>
      </Modal>
      <ul>
        {tasks.map((task, index) => (
          <Task key={index} index={index} task={task} completeTask={completeTask} />
        ))}
      </ul>
    </div>
  );
};

export default Tasks;

