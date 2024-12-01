#!/usr/bin/env python

from functools import reduce

lines = [row.strip() for row in open('01.input').readlines()]

left = []
right = []

for line in lines:
    l, r = line.split()
    left.append(int(l))
    right.append(int(r))

left.sort()
right.sort()

print(reduce(lambda x, y: x + y, map(lambda lr: abs(lr[0] - lr[1]), zip(left, right))))
