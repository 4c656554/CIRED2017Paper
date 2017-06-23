"# CIRED2017Paper" 


This directory contains the solidity code and testing instructions for the code referenced in the following paper:

Thomas, Long, Burnamp, Wu, Jenkins "Automation of the Supplier Role in the GB Power System using Blockchain Based Smart Contracts" presented at CIRED 2017, Glasgow.

The proposed algorithm combines a merit-order type method to ascertain a market price. It then has a peer to peer penalty and reward system based on how closely the users estimate matched their actual usage, and, in the event of a mismatch, whether their misestimation tended to balance, or unbalance the system.

As alluded to in the paper, this code needs a bit of work to be implemented practically. It contains a number of loops. In the test run I artifically raised the block gas limit to ensure that it functioned.
