#!/usr/bin/env ruby

require 'numo/narray'

class Map
  attr_accessor :map

  def initialize(input)
    @height = input.size
    @width = input[0].size * 2
    @map = Numo::UInt8.zeros(@height, @width)

    @height.times do |y|
      @width.times do |x|
        case input[y][x]
        when '.'
          @map[y, x * 2] = 0
          @map[y, x * 2 + 1] = 0
        when '#'
          @map[y, x * 2] = 1
          @map[y, x * 2 + 1] = 1
        when 'O'
          @map[y, x * 2] = 4
          @map[y, x * 2 + 1] = 5
        when '@'
          @robot_y = y
          @robot_x = x * 2
          @map[y, x * 2] = 3
          @map[y, x * 2 + 1] = 0
        end
      end
    end
  end

  def push!(front, dy, dx)
    return true if front.all? { |y, x| @map[y, x] == 0 }
    return false if front.any? { |y, x| @map[y + dy, x + dx] == 1 }

    new_front = []
    front.each do |y, x|
      unless @map[y + dy, x + dx] == 0
        new_front << [y + dy, x + dx]
        if dy != 0 &&
           @map[y + dy, x] == 4 # [
          new_front << [y + dy, x + dx + 1]
        elsif dy != 0 &&
              @map[y + dy, x] == 5 # ]
          new_front << [y + dy, x + dx - 1]
        end
      end
    end
    new_front.uniq!

    push!(new_front, dy, dx)

    if front.all? { |y, x| @map[y + dy, x + dx] == 0 }
      front.each do |y, x|
        @map[y + dy, x + dx] = @map[y, x]
        @map[y, x] = 0
      end
      true
    end
  end

  def step!(direction)
    case direction
    when '^'
      dy = -1
      dx = 0
    when '>'
      dy = 0
      dx = 1
    when 'v'
      dy = 1
      dx = 0
    when '<'
      dy = 0
      dx = -1
    end

    if push!([[@robot_y, @robot_x]], dy, dx)
      @robot_y += dy
      @robot_x += dx
    end
  end

  def score
    coord = 0
    @height.times do |y|
      @width.times do |x|
        coord += 100 * y + x if @map[y, x] == 4
      end
    end
    coord
  end

  def inspect
    to_s
  end

  def to_s
    chars = ['.', '#', 'X', '@', '[', ']']
    s = "<#{self.class}:\n"
    @height.times do |y|
      @width.times do |x|
        s += chars[@map[y, x]]
      end
      s += "\n"
    end
    s += '>'
    s
  end
end

input = File.read('15.input').lines.map(&:strip)

lines = []
until (line = input.shift).empty?
  lines << line
end

map = Map.new lines

instructions = input.join.chars

instructions.each do |insn|
  map.step! insn
end

puts map.score
