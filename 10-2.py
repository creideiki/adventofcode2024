#!/usr/bin/env python

import numpy


class Map:
    def __init__(self, input):
        self.height = len(input)
        self.width = len(input[0])
        self.trailheads = []
        self.peaks = []
        self.map = numpy.zeros((self.height, self.width), dtype=numpy.uint8)
        for y in range(self.height):
            for x in range(self.width):
                match input[y][x]:
                    case '.':
                        self.map[y, x] = 255
                    case '0':
                        self.map[y, x] = 0
                        self.trailheads.append((y, x))
                    case '9':
                        self.map[y, x] = 9
                        self.peaks.append((y, x))
                    case _:
                        self.map[y, x] = int(input[y][x])

    def trace(self, y, x, visited):
        if (y, x) in visited:
            return 0

        cur_height = self.map[y, x]

        if cur_height == 9:
            return 1

        score = 0
        if y + 1 < self.height and self.map[y + 1, x] == cur_height + 1:
            score += self.trace(y + 1, x, visited + [(y, x)])
        if y - 1 >= 0 and self.map[y - 1, x] == cur_height + 1:
            score += self.trace(y - 1, x, visited + [(y, x)])
        if x + 1 < self.width and self.map[y, x + 1] == cur_height + 1:
            score += self.trace(y, x + 1, visited + [(y, x)])
        if x - 1 >= 0 and self.map[y, x - 1] == cur_height + 1:
            score += self.trace(y, x - 1, visited + [(y, x)])
        return score

    def hike(self):
        score = 0
        for t in self.trailheads:
            score += self.trace(t[0], t[1], [])
        return score


map = Map([row.strip() for row in open('10.input').readlines()])
print(map.hike())
