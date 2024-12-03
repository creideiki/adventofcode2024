#!/usr/bin/env python

from functools import reduce
import re

input = open('03.input').read()

inst = re.compile('mul\\([0-9]+,[0-9]+\\)')

print(reduce(lambda x, y: x + y,
             map(lambda terms: int(terms[0]) * int(terms[1]),
                 [mul[4:-1].split(',') for mul in re.findall(inst, input)])))
