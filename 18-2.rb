#!/usr/bin/env ruby

require 'numo/narray'
require 'algorithms'

class Map
  attr_accessor :map, :costs

  def initialize
    @height = 71
    @width = 71
    @map = Numo::UInt8.zeros(@height, @width)
  end

  def push!(line)
    x, y = line.split(',').map(&:to_i)
    @map[y, x] = 1
  end

  def solve
    costs = Numo::UInt32.new(@height, @width).fill Numo::UInt32::MAX

    queue = Containers::MinHeap.new
    queue.push(0, { y: 0, x: 0 })

    until queue.empty?
      cost = queue.next_key
      pos = queue.pop

      y = pos[:y]
      x = pos[:x]

      costs[y, x] = cost

      return cost if y == @height - 1 && x == @width - 1

      if y > 0 && @map[y - 1, x].zero? && costs[y - 1, x] > (cost + 1) && costs[y - 1, x] != Numo::UInt32::MAX - 1
        queue.push(cost + 1, { y: y - 1, x: x })
        costs[y - 1, x] = Numo::UInt32::MAX - 1
      end
      if x < @width - 1 && @map[y, x + 1].zero? && costs[y, x + 1] > (cost + 1) && costs[y, x + 1] != Numo::UInt32::MAX - 1
        queue.push(cost + 1, { y: y, x: x + 1 })
        costs[y, x + 1] = Numo::UInt32::MAX - 1
      end
      if y < @height - 1 && @map[y + 1, x].zero? && costs[y + 1, x] > (cost + 1) && costs[y + 1, x] != Numo::UInt32::MAX - 1
        queue.push(cost + 1, { y: y + 1, x: x })
        costs[y + 1, x] = Numo::UInt32::MAX - 1
      end
      if x > 0 && @map[y, x - 1].zero? && costs[y, x - 1] > (cost + 1) && costs[y, x - 1] != Numo::UInt32::MAX - 1
        queue.push(cost + 1, { y: y, x: x - 1 })
        costs[y, x - 1] = Numo::UInt32::MAX - 1
      end
    end
  end

  def inspect
    to_s
  end

  def to_s
    chars = ['.', '#']
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

map = Map.new
bytes = File.read('18.input').lines.map(&:strip)
known_good = bytes[..1023]
known_good.each { |b| map.push! b }
bytes[1024..].each do |byte|
  map.push! byte
  unless map.solve
    puts byte
    break
  end
end
