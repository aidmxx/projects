#!/bin/bash
gcc -g smallest_triangle.c -o smallest_triangle
python3 gen_points.py -N=20 -mindist=2 -rseed=3 | ./smallest_triangle