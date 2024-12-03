#!/usr/bin/env ruby

input = File.read('03.input')

inst = /mul\([[:digit:]]+,[[:digit:]]+\)/

puts input.scan(inst).map { |mul| mul[4..-2].split(',').map(&:to_i).reduce(&:*) }.sum
