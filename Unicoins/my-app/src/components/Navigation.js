import React from 'react';
import { Navbar, Container, Nav } from 'react-bootstrap';

const Navigation = () => (
  <Navbar bg="dark" variant="dark">
    <Container>
      <Navbar.Brand href="/">UNCollaboration</Navbar.Brand>
      <Nav className="me-auto">
        <Nav.Link href="/">Home</Nav.Link>
        <Nav.Link href="/tasks">Tasks</Nav.Link>
        <Nav.Link href="/projects">Projects</Nav.Link>
      </Nav>
    </Container>
  </Navbar>
);

export default Navigation;
