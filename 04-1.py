#!/usr/bin/env python

haystack = [row.strip() for row in open('04.input').readlines()]

def find_dir(needle, x, y, dx, dy):
    if len(needle) == 0:
        return True
    if x < 0 or x >= len(haystack[0]) or \
       y < 0 or y >= len(haystack):
        return False
    if haystack[y][x] != needle[0]:
        return False

    return find_dir(needle[1:], x + dx, y + dy, dx, dy)

def find(x, y):
    needle = 'XMAS'

    count = 0
    for dx in [-1, 0, 1]:
        for dy in [-1, 0, 1]:
            if dx == 0 and dy == 0:
                continue

            if find_dir(needle, x, y, dx, dy):
                count += 1

    return count


count = 0
for y in range(len(haystack)):
    for x in range(len(haystack[0])):
        count += find(x, y)

print(count)
