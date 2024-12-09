#!/usr/bin/env python

import numpy


class Puzzle:
    def __init__(self, input):
        self.height = len(input)
        self.width = len(input[0])
        self.map = numpy.zeros((self.height, self.width), dtype=numpy.uint8)
        for y in range(self.height):
            for x in range(self.width):
                self.map[y, x] = ord(input[y][x])

        mas = [
            [ord('M'), ord('.'), ord('S')],
            [ord('.'), ord('A'), ord('.')],
            [ord('M'), ord('.'), ord('S')],
        ]
        self.mas_height = len(mas)
        self.mas_width = len(mas[0])
        xmas = numpy.zeros((self.mas_height, self.mas_width), dtype=numpy.uint8)
        for y in range(self.mas_height):
            for x in range(self.mas_width):
                xmas[y, x] = mas[y][x]

        self.xmases = [xmas, numpy.rot90(xmas, 1), numpy.rot90(xmas, 2), numpy.rot90(xmas, 3)]

    def match(self, y, x):
        for xmas in self.xmases:
            res = True
            for my in range(self.mas_height):
                for mx in range(self.mas_width):
                    if xmas[my, mx] == 46:  # .
                        continue

                    if xmas[my, mx] != self.map[y + my, x + mx]:
                        res = False
            if res:
                return True

        return False

    def count_matches(self):
        count = 0
        for y in range(self.height - self.mas_height + 1):
            for x in range(self.width - self.mas_width + 1):
                if self.match(y, x):
                    count += 1
        return count


input = [row.strip() for row in open('04.input').readlines()]
puzzle = Puzzle(input)
print(puzzle.count_matches())
