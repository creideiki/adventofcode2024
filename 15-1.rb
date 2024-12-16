#!/usr/bin/env ruby

require 'numo/narray'

class Map
  attr_accessor :map

  def initialize(input)
    @height = input.size
    @width = input[0].size
    @map = Numo::UInt8.zeros(@height, @width)

    @height.times do |y|
      @width.times do |x|
        @map[y, x] = case input[y][x]
                     when '.'
                       0
                     when '#'
                       1
                     when 'O'
                       2
                     when '@'
                       @robot_y = y
                       @robot_x = x
                       3
                     end
      end
    end
  end

  def push!(y, x, dy, dx)
    return true if @map[y, x] == 0

    dest_y = y + dy
    dest_x = x + dx

    return false if @map[dest_y, dest_x] == 1

    push!(dest_y, dest_x, dy, dx)

    if @map[dest_y, dest_x] == 0
      @map[dest_y, dest_x] = @map[y, x]
      @map[y, x] = 0
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

    if push!(@robot_y, @robot_x, dy, dx)
      @robot_y += dy
      @robot_x += dx
    end
  end

  def score
    coord = 0
    @height.times do |y|
      @width.times do |x|
        coord += 100 * y + x if @map[y, x] == 2
      end
    end
    coord
  end

  def inspect
    to_s
  end

  def to_s
    chars = ['.', '#', 'O', '@']
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
