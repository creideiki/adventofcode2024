#!/usr/bin/env ruby

class Stones
  def initialize(line)
    @stones = line.split.map(&:to_i)
  end

  def blink!
    new_stones = []
    @stones.each do |stone|
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
    end
    @stones = new_stones
  end

  def score
    @stones.size
  end

  def inspect
    to_s
  end

  def to_s
    "<#{self.class}: #{@stones}>"
  end
end

stones = Stones.new File.read('11.input').strip

25.times { stones.blink! }

puts stones.score
