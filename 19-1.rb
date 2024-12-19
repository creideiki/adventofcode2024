#!/usr/bin/env ruby

class Pattern
  def initialize(pattern, towels)
    @pattern = pattern
    @towels = towels.split(',').map(&:strip)
  end

  def arrange_towels(arrangement, remaining_pattern, enum)
    enum.yield arrangement if remaining_pattern.empty?

    @towels.each do |towel|
      next unless remaining_pattern.start_with? towel

      arrange_towels(arrangement + towel, remaining_pattern[towel.size..], enum)
    end
  end

  def solve
    solutions = Enumerator.new do |enum|
      arrange_towels('', @pattern, enum)
    end

    solutions.peek
    1
  rescue StopIteration
    0
  end
end

lines = File.read('19.input').lines.map(&:strip)
towels = lines[0]
patterns = lines[2..].map { |l| Pattern.new(l, towels) }
puts patterns.map(&:solve).sum
