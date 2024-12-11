#!/usr/bin/env ruby

require 'memo_wise'

class Stones
  prepend MemoWise

  def initialize(line)
    @stones = line.split.map(&:to_i)
  end

  def change(stone)
    new_stones = []
    if stone.zero?
      new_stones << 1
    elsif (Math.log10(stone).floor + 1).even?
      engraving = stone.to_s
      half = (Math.log10(stone).floor + 1) / 2
      new_stones << engraving[..half - 1].to_i
      new_stones << engraving[half..].to_i
    else
      new_stones << stone * 2024
    end
    new_stones
  end

  memo_wise :change

  def length(stone, steps)
    return 1 if steps.zero?

    new_stones = change(stone)
    new_stones.map { |s| length(s, steps - 1) }.sum
  end

  memo_wise :length

  def score(steps)
    @stones.map { |s| length(s, steps) }.sum
  end

  def inspect
    to_s
  end

  def to_s
    "<#{self.class}: #{@stones}>"
  end
end

stones = Stones.new File.read('11.input').strip
puts stones.score 75
