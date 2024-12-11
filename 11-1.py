#!/usr/bin/env python

import math


class Stones:
    def __init__(self, line):
        self.stones = [int(s) for s in line.split()]

    def blink(self):
        new_stones = []
        for stone in self.stones:
            if stone == 0:
                new_stones.append(1)
            elif (math.floor(math.log10(stone)) + 1) % 2 == 0:
                engraving = str(stone)
                half = int((math.floor(math.log10(stone)) + 1) / 2)
                new_stones.append(int(engraving[:half]))
                new_stones.append(int(engraving[half:]))
            else:
                new_stones.append(stone * 2024)

        self.stones = new_stones

    def score(self):
        return len(self.stones)


stones = Stones(open('11.input').read().strip())

for _ in range(25):
    stones.blink()

print(stones.score())
