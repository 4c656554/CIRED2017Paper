"# CIRED2017Paper" 


This directory contains the solidity code and testing instructions for the code referenced in the following paper (I'll add a link when it becomes available):

Thomas, Long, Burnamp, Wu, Jenkins "Automation of the Supplier Role in the GB Power System using Blockchain Based Smart Contracts" presented at CIRED 2017, Glasgow.

The proposed algorithm combines a merit-order type method to ascertain a market price. It then has a peer to peer penalty and reward system based on how closely the users estimate matched their actual usage, and, in the event of a mismatch, whether their misestimation tended to balance, or unbalance the system.

In the test run I raised the block gas limit to ensure that it functioned. The code contains a number of loops - I aim to find a way to remove these in future.
