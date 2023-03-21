import React from 'react';
import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
import Home from './Home';
import Tasks from './Tasks';
import Projects from './Projects';

const Main = () => (
  <Router>
    <Switch>
      <Route path="/" exact component={Home} />
      <Route path="/tasks" component={Tasks} />
      <Route path="/projects" component={Projects} />
    </Switch>
  </Router>
);

export default Main;

