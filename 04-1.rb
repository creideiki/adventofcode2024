#!/usr/bin/env ruby

$haystack = File.read('04.input').lines.map(&:strip).map(&:chars)

def find_dir(needle, x, y, dx, dy)
  return true if needle.empty?
  return false if x < 0 or
                  x >= $haystack[0].size or
                  y < 0 or
                  y >= $haystack.size
  return false unless $haystack[y][x] == needle[0]

  find_dir(needle[1..], x + dx, y + dy, dx, dy)
end

def find(x, y)
  needle = 'XMAS'

  count = 0
  [-1, 0, 1].each do |dx|
    [-1, 0, 1].each do |dy|
      next if dx.zero? and dy.zero?

      count += 1 if find_dir(needle, x, y, dx, dy)
    end
  end
  count
end

count = 0
$haystack.each_index do |y|
  $haystack[0].each_index do |x|
    count += find(x, y)
  end
end

puts count
