import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import { Container, Navbar, Nav } from 'react-bootstrap';
import Home from './Home';
import Tasks from './Tasks';
import Projects from './Projects';
import './Main.css';

const Main = () => (
  <Router>
    <Navbar bg="dark" variant="dark" expand="lg" className="mb-4">
      <Container>
        <Navbar.Brand href="/">UNCollaboration</Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="ml-auto">
            <Nav.Link href="/">Home</Nav.Link>
            <Nav.Link href="/tasks">Tasks</Nav.Link>
            <Nav.Link href="/projects">Projects</Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
    <Container>
      <Switch>
        <Route path="/" exact component={Home} />
        <Route path="/tasks" component={Tasks} />
        <Route path="/projects" component={Projects} />
      </Switch>
    </Container>
    <footer className="mt-4 text-center">
      <p>UNCollaboration Platform &copy; {new Date().getFullYear()}</p>
    </footer>
  </Router>
);

export default Main;

