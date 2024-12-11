#!/usr/bin/env python

import functools
import math


class Stones:
    def __init__(self, line):
        self.stones = [int(s) for s in line.split()]

    @functools.cache
    def change(self, stone):
        new_stones = []
        if stone == 0:
            new_stones.append(1)
        elif (math.floor(math.log10(stone)) + 1) % 2 == 0:
            engraving = str(stone)
            half = int((math.floor(math.log10(stone)) + 1) / 2)
            new_stones.append(int(engraving[:half]))
            new_stones.append(int(engraving[half:]))
        else:
            new_stones.append(stone * 2024)

        return new_stones

    @functools.cache
    def length(self, stone, steps):
        if steps == 0:
            return 1

        new_stones = self.change(stone)
        return sum([self.length(s, steps - 1) for s in new_stones])

    def score(self, steps):
        return sum([self.length(s, steps) for s in self.stones])


stones = Stones(open('11.input').read().strip())
print(stones.score(75))
