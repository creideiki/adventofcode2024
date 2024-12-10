#!/usr/bin/env ruby

require 'numo/narray'

class Map
  attr_reader :map, :visited

  def initialize(input)
    @height = input.size
    @width = input[0].size
    @trailheads = []
    @peaks = []
    @map = Numo::UInt8.zeros(@height, @width)
    @height.times do |y|
      @width.times do |x|
        case input[y][x]
        when '.'
          @map[y, x] = 255
        when '0'
          @map[y, x] = 0
          @trailheads << [y, x]
        when '9'
          @map[y, x] = 9
          @peaks << [y, x]
        else
          @map[y, x] = input[y][x].to_i
        end
      end
    end
  end

  def trace(y, x, visited)
    return 0 if visited.include? [y, x]

    cur_height = @map[y, x]

    return 1 if cur_height == 9

    score  = 0
    score += trace(y + 1, x, visited + [y, x]) if y + 1 < @height && @map[y + 1, x] == cur_height + 1
    score += trace(y - 1, x, visited + [y, x]) if y - 1 >= 0 && @map[y - 1, x] == cur_height + 1
    score += trace(y, x + 1, visited + [y, x]) if x + 1 < @width && @map[y, x + 1] == cur_height + 1
    score += trace(y, x - 1, visited + [y, x]) if x - 1 >= 0 && @map[y, x - 1] == cur_height + 1
    score
  end

  def hike
    score = 0
    @trailheads.each do |t|
      score += trace(t[0], t[1], [])
    end
    score
  end

  def inspect
    to_s
  end

  def to_s
    s = "<#{self.class}:\n"
    @height.times do |y|
      @width.times do |x|
        s += case @map[y, x]
             when 255
               '.'
             else
               @map[y, x].to_s
             end
      end
      s += "\n"
    end
    s += '>'
    s
  end
end

map = Map.new File.read('10.input').lines.map(&:strip)
puts map.hike
