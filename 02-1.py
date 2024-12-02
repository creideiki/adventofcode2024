#!/usr/bin/env python

class Report:
    def __init__(self, line):
        self.levels = [int(i) for i in line.split()]
        self.gen_differences()

    def gen_differences(self):
        self.differences = []
        for i in range(len(self.levels) - 1):
            self.differences.append(self.levels[i + 1] - self.levels[i])

    def safe_p(self):
        if not (all([d > 0 for d in self.differences]) or
                all([d < 0 for d in self.differences])):
            return False

        return all([abs(d) >= 1 and abs(d) <= 3 for d in self.differences])


lines = [row.strip() for row in open('02.input').readlines()]

print([Report(line).safe_p() for line in lines].count(True))
