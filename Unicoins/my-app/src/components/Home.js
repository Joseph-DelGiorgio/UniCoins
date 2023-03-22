import React from 'react';
import { Container, Row, Col } from 'react-bootstrap';
import './Home.css';

const Home = () => (
  <Container>
    <Row className="justify-content-center align-items-center">
      <Col md={8} className="home-content">
        <h1 className="display-4">Welcome to UNCollaboration</h1>
        <p className="lead">
          UNCollaboration is a platform that brings together volunteers and project managers to collaborate on projects, participate in tasks, and earn rewards.
        </p>
        <hr className="my-4" />
        <p>
          Join our growing community and contribute to meaningful projects, learn new skills, and make a difference.
        </p>
      </Col>
    </Row>
  </Container>
);

export default Home;

