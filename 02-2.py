#!/usr/bin/env python

from itertools import combinations

class Report:
    def __init__(self, line):
        self.levels = [int(i) for i in line.split()]

    def safe_levels_p(self, levels):
        differences = []
        for i in range(len(levels) - 1):
            differences.append(levels[i + 1] - levels[i])
        if not (all([d > 0 for d in differences]) or
                all([d < 0 for d in differences])):
            return False
        return all([abs(d) >= 1 and abs(d) <= 3 for d in differences])

    def safe_p(self):
        if self.safe_levels_p(self.levels):
            return True
        return any([self.safe_levels_p(l) for l in combinations(self.levels, len(self.levels) - 1)])


lines = [row.strip() for row in open('02.input').readlines()]

print([Report(line).safe_p() for line in lines].count(True))
