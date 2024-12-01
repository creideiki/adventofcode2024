#!/usr/bin/env ruby

lines = File.read('01.input').lines.map(&:strip)

left = []
right = []

lines.each do |line|
  l, r = line.split
  left << l.to_i
  right << r.to_i
end

puts left.map { |l| l * right.count(l) }.reduce &:+
