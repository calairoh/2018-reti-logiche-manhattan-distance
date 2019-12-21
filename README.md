# 2018-reti-logiche-manhattan-distance
VHDL program for Xilinx FPGA for the manhattan distance calculus. 

## Manhattan distance
The taxicab distance, _d_, between two vectors _p_ ,_q_ in an n-dimensional real vector space with fixed Cartesian coordinate system, is the sum of the lengths of the projections of the line segment between the points onto the coordinate axes. 
_Source: [Wikipedia](https://en.wikipedia.org/wiki/Taxicab_geometry)_

## How it works
Starting from a 256x256 matrix and a set of eight points in the matrix called centroids. The algorithm will calculate which of those centroids are the closest to another fixed point.

## Description
In the `src` folder you will find two files:
* `FSM.vhd`: it contains the Final State Machine that compute the calculation.
* `ROM.vhd`: it represents the ROM that contains the centroides, with `x` and `y` coordinates, and the point on which compute the distance. The result of the computation will be write in the last memory space (record `19`) of the ROM.

## Scope
Program made for the Reti Logiche's final exam for Politecnico di Milano, A/A 2018-2019.
