#!/usr/bin/env ruby

require 'numo/narray'

class Puzzle
  def initialize(input)
    @height = input.size
    @width = input[0].size
    @map = Numo::UInt8.zeros(@height, @width)
    @height.times do |y|
      @width.times do |x|
        @map[y, x] = input[y][x].codepoints[0]
      end
    end

    mas = [
      'M.S'.codepoints,
      '.A.'.codepoints,
      'M.S'.codepoints
    ]
    @mas_height = mas.size
    @mas_width = mas[0].size
    xmas = Numo::UInt8.zeros(3, 3)
    @mas_height.times do |y|
      @mas_width.times do |x|
        xmas[y, x] = mas[y][x]
      end
    end
    @xmases = [xmas, xmas.rot90(1), xmas.rot90(2), xmas.rot90(3)]
  end

  def match?(y, x)
    @xmases.any? do |xmas|
      res = true
      @mas_height.times do |my|
        @mas_width.times do |mx|
          next if xmas[my, mx] == 46 # .

          res = false if xmas[my, mx] != @map[y + my, x + mx]
        end
      end
      res
    end
  end

  def count_matches
    count = 0
    (@height - @mas_height + 1).times do |y|
      (@width - @mas_width + 1).times do |x|
        count += 1 if match?(y, x)
      end
    end
    count
  end
end

input = File.read('04.input').lines.map(&:strip)
puzzle = Puzzle.new(input)
puts puzzle.count_matches
