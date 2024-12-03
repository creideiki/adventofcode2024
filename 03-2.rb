#!/usr/bin/env ruby

input = File.read('03.input')

inst = /do\(\)|don't\(\)|mul\([[:digit:]]+,[[:digit:]]+\)/

res = 0
enabled = true

input.scan(inst).each do |i|
  case i
  when 'do()'
    enabled = true
  when 'don\'t()'
    enabled = false
  else
    res += i[4..-2].split(',').map(&:to_i).reduce(&:*) if enabled
  end
end

puts res
