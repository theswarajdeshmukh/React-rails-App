import React, { useState } from "react";

import tasksApi from "apis/tasks";
import Container from "components/Container";

import Form from "./Form";

const Create = ({ history }) => {
  const [title, setTitle] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async event => {
    event.preventDefault();
    setLoading(true);
    try {
      await tasksApi.create({ title });
      setLoading(false);
      history.push("/dashboard");
      //The history object is provided by the react-router-dom package and it is passed as a prop into each component rendered by the Router.
      //The history object has various methods as well which can be used to manually control the browser history. Like the push method we have used.
      // The push method accepts a path and pushes this path into the history stack thus updating the current location.
    } catch (error) {
      logger.error(error);
      setLoading(false);
    }
  };

  return (
    <Container>
      <Form handleSubmit={handleSubmit} loading={loading} setTitle={setTitle} />
    </Container>
  );
};

export default Create;
