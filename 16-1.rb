#!/usr/bin/env ruby

require 'numo/narray'
require 'algorithms'

class Map
  attr_accessor :map

  def initialize(input)
    @height = input.size
    @width = input[0].size
    @map = Numo::UInt8.zeros(@height, @width)
    @costs = Numo::UInt32.new(@height, @width).fill Numo::UInt32::MAX

    @height.times do |y|
      @width.times do |x|
        case input[y][x]
        when '.'
          @map[y, x] = 0
        when '#'
          @map[y, x] = 1
        when 'S'
          @map[y, x] = 2
          @start = { y: y, x: x }
        when 'E'
          @map[y, x] = 3
          @end = { y: y, x: x }
        end
      end
    end
  end

  def solve!
    queue = Containers::MinHeap.new
    queue.push(0, { y: @start[:y], x: @start[:x], dir: :east })

    until queue.empty?
      cost = queue.next_key
      pos = queue.pop

      y = pos[:y]
      x = pos[:x]
      dir = pos[:dir]

      @costs[y, x] = cost if cost < @costs[y, x]

      return cost if y == @end[:y] && x == @end[:x]

      case dir
      when :north
        queue.push(cost + 1, { y: y - 1, x: x, dir: :north }) if @map[y - 1, x] != 1 && @costs[y - 1, x] > cost + 1
        queue.push(cost + 1000, { y: y, x: x, dir: :east }) if @map[y, x + 1] != 1 && @costs[y, x + 1] > cost + 1000
        queue.push(cost + 1000, { y: y, x: x, dir: :west }) if @map[y, x - 1] != 1 && @costs[y, x - 1] > cost + 1000
      when :east
        queue.push(cost + 1, { y: y, x: x + 1, dir: :east }) if @map[y, x + 1] != 1 && @costs[y, x + 1] > cost + 1
        queue.push(cost + 1000, { y: y, x: x, dir: :south }) if @map[y + 1, x] != 1 && @costs[y + 1, x] > cost + 1000
        queue.push(cost + 1000, { y: y, x: x, dir: :north }) if @map[y - 1, x] != 1 && @costs[y - 1, x] > cost + 1000
      when :south
        queue.push(cost + 1, { y: y + 1, x: x, dir: :south }) if @map[y + 1, x] != 1 && @costs[y + 1, x] > cost + 1
        queue.push(cost + 1000, { y: y, x: x, dir: :west }) if @map[y, x - 1] != 1 && @costs[y, x - 1] > cost + 1000
        queue.push(cost + 1000, { y: y, x: x, dir: :east }) if @map[y, x + 1] != 1 && @costs[y, x + 1] > cost + 1000
      when :west
        queue.push(cost + 1, { y: y, x: x - 1, dir: :west }) if @map[y, x - 1] != 1 && @costs[y, x - 1] > cost + 1
        queue.push(cost + 1000, { y: y, x: x, dir: :north }) if @map[y - 1, x] != 1 && @costs[y - 1, x] > cost + 1000
        queue.push(cost + 1000, { y: y, x: x, dir: :south }) if @map[y + 1, x] != 1 && @costs[y + 1, x] > cost + 1000
      end
    end
  end

  def inspect
    to_s
  end

  def to_s
    chars = ['.', '#', 'S', 'E']
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

map = Map.new File.read('16.input').lines.map(&:strip)
puts map.solve!
