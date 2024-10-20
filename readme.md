
# **Project 2: Gossip Algorithm and Push-Sum Algorithm**

## Project Overview

This is **Project 2** in the course **Distributed Operating System Principles (COP 5615)**. In this project, I implemented the **Gossip** and **Push-Sum** algorithms using the **Pony** programming language on an arbitrary-sized network with 4 different topologies.

### Group Members
- **Leqi Chen**

---

## What is Working

All project requirements have been fully implemented, with a slight modification to the specification in order to improve the performance of the **Push-Sum** algorithm.

---

## Algorithms

### Gossip Algorithm
- **Starting**: A participant (actor) is told or sent a rumor (fact) by the main process.
- **Step**: Each actor selects a random neighbor and shares the rumor.
- **Termination**: Each actor tracks how many times it has heard the rumor. It stops transmitting once it has heard the rumor 10 times.

### Push-Sum Algorithm
- **State**: Each actor \( A_i \) maintains two quantities: \( s \) and \( w \). Initially, \( s = x_i = i \) (where actor number \( i \) has value \( i \); other distributions can be used if desired) and \( w = 1 \).
- **Starting**: One of the actors is asked to start by the main process.
- **Receive**: Messages sent and received are pairs of the form \( (s, w) \). Upon receiving a message, an actor adds the received pair to its own corresponding values and then selects a random neighbor to send a message.
- **Send**: When sending a message, half of \( s \) and \( w \) is kept by the sending actor, and half is sent to the neighbor.
- **Sum Estimate**: At any given moment, the sum estimate is \( s/w \), where \( s \) and \( w \) are the current values of an actor.
- **Termination**: If an actor’s ratio \( s/w \) does not change by more than \( 10^{-10} \) over 3 consecutive rounds, the actor terminates.

---

## Topologies

1. **Full Network**
2. **Line Topology**
3. **3D Grid**
4. **Imperfect 3D Grid**

---

## Running the Program

The program accepts the following command-line arguments:

```bash
./pro2 numNodes topology algorithm
```

- **numNodes**: The number of nodes (actors) in the simulation.
- **topology**: The network topology to use (`full`, `line`, `3D`, `imp3D`).
- **algorithm**: The algorithm to simulate (`gossip`, `push-sum`).

### Example Command:

```bash
./pro2 100 3D gossip
```

This command runs the **Gossip** algorithm on a **3D Grid** topology with 100 nodes.

---

## Largest Networks Handled

### Gossip Algorithm:
- **Full Network**: Simulated up to **15,000** nodes.
- **3D Grid**: Simulated up to **10,000** nodes.
- **Line Topology**: Simulated up to **8,000** nodes.
- **Imperfect 3D Grid**: Simulated up to **10,000** nodes.

### Push-Sum Algorithm:
- **Full Network**: Simulated up to **16,000** nodes.
- **3D Grid**: Simulated up to **20,000** nodes.
- **Line Topology**: Simulated up to **10,000** nodes.
- **Imperfect 3D Grid**: Simulated up to **20,000** nodes.

---

