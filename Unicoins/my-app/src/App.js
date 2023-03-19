import { Web3Provider } from './contexts/Web3Context';
import Navbar from './components/Navbar';
import Tasks from './components/Tasks';
import Projects from './components/Projects';
import './App.css';

function App() {
  return (
    <Web3Provider>
      <div className="App">
        <Navbar />
        <Tasks />
        <Projects />
      </div>
    </Web3Provider>
  );
}

export default App;
