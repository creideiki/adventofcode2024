#!/usr/bin/env ruby

require 'numo/narray'

class Map
  def initialize(input)
    @height = input.size
    @width = input[0].size
    @map = Numo::UInt8.zeros(@height, @width)
    @height.times do |y|
      @width.times do |x|
        case input[y][x]
        when '.'
          @map[y, x] = 0
        when '#'
          @map[y, x] = 1
        when '^'
          @map[y, x] = 2
          @guard_y = y
          @guard_x = x
          @guard_dir = :north
        end
      end
    end
  end

  def step!
    case @guard_dir
    when :north
      dy = -1
      dx = 0
    when :east
      dy = 0
      dx = 1
    when :south
      dy = 1
      dx = 0
    when :west
      dy = 0
      dx = -1
    end

    next_x = @guard_x + dx
    next_y = @guard_y + dy

    if next_x < 0 or next_x >= @width or
         next_y < 0 or next_y >= @height
      @guard_x = next_x
      @guard_y = next_y
      true
    elsif @map[next_y, next_x] == 1
      @guard_dir = case @guard_dir
                   when :north
                     :east
                   when :east
                     :south
                   when :south
                     :west
                   when :west
                     :north
                   end
      false
    else
      @map[next_y, next_x] = 2
      @guard_x = next_x
      @guard_y = next_y
      false
    end
  end

  def visited
    count = 0
    @map.each { |x| count += 1 if x == 2 }
    count
  end

  def inspect
    to_s
  end

  def to_s
    s  = "<#{self.class}:\n"
    s += "Guard: (#{@guard_y}, #{@guard_x}) #{@guard_dir}\n"
    @height.times do |y|
      @width.times do |x|
        s += case @map[y, x]
             when 0
               '.'
             when 1
               '#'
             when 2
               'X'
             end
      end
      s += "\n"
    end
    s += ">"
    s
  end
end

map = Map.new File.read('06.input').lines.map(&:strip)

until map.step!
end

puts map.visited
