# GRC-IDS
This repository contains code for the article titled Globalized Robust Markov Perfect Equilibrium forDiscounted Stochastic Games and its Application onIntrusion Detection in Wireless Sensor Networks. Get the [article here](https://arxiv.org/abs/1909.11039).


## Abstract
In this article, we study a discounted stochastic game to model resource optimal intrusion detection in wireless sensor networks. To address the problem of uncertainties in various network parameters, we propose a globalized robust game theoretic framework for discounted robust stochastic games. A robust solution to the considered problem is an optimal point that is feasible for all realizations of data from a given uncertainty set. To allow a controlled violation of the constraints when the parameters move out of the uncertainty set, the concept of globalized robust framework comes into view. In this article, we formulate a globalized robust counterpart for the discounted stochastic game under consideration. With the help of globalized robust optimization, a concept of globalized robust Markov perfect equilibrium is introduced. The existence of such an equilibrium is shown for a discounted stochastic game when the number of actions of the players is finite. The contraction mapping theorem, Kakutani fixed point the-orem and the concept of equicontinuity are used to prove the existence result. To compute aglobalized robust Markov perfect equilibrium for the considered discounted stochastic game, a tractable representation of the proposed globalized robust counterpart is also provided.  Using the derived tractable representation, we formulate a globalized robust intrusion detection system for wireless sensor networks.


## Instructions
The AMPL code is the formulation for Theorem 2 of the article. It can be run standalone on a system with [AMPL](http://ampl.com) installed or on web via [NEOS server](https://neos-server.org/neos/).

There are a lot of solvers available for Nonlinear Constrained Programming (you can find a [list here](https://neos-server.org/neos/solvers/index.html)). We've used [KNITRO](https://www.artelys.com/solvers/knitro/) solver which finds the equilibrium solution for a small scale WSN of 15 nodes within a minute.
