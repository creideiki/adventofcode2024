#!/usr/bin/env python

from functools import reduce
import re

input = open('03.input').read()

inst = re.compile('do\\(\\)|don\'t\\(\\)|mul\\([0-9]+,[0-9]+\\)')

res = 0
enabled = True

for i in re.findall(inst, input):
    match i:
        case 'do()':
            enabled = True
        case 'don\'t()':
            enabled = False
        case _:
            if enabled:
                res += reduce(lambda x, y: x * y,
                              map(lambda s: int(s),
                                  i[4:-1].split(',')))

print(res)
