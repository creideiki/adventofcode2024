#!/usr/bin/env ruby

require 'numo/narray'

class Map
  attr_reader :antennae, :map, :antinodes

  def initialize(input)
    @height = input.size
    @width = input[0].size
    @antennae = Hash.new []
    @map = Numo::UInt8.zeros(@height, @width)
    @antinodes = Numo::UInt8.zeros(@height, @width)
    @height.times do |y|
      @width.times do |x|
        case input[y][x]
        when '.'
          @map[y, x] = 0
        else
          @map[y, x] = input[y][x].codepoints[0]
          @antennae[input[y][x].codepoints[0]] += [[y, x]]
        end
      end
    end
  end

  def find_antinodes(a, b)
    dy = b[0] - a[0]
    dx = b[1] - a[1]

    possibles = [a, b]

    y = a[0] + dy * 2
    x = a[1] + dx * 2
    while y < @height && x < @width && y >= 0 && x >= 0
      possibles << [y, x]
      y += dy
      x += dx
    end

    y = a[0] - dy
    x = a[1] - dx
    while y < @height && x < @width && y >= 0 && x >= 0
      possibles << [y, x]
      y -= dy
      x -= dx
    end

    possibles
  end

  def fill!
    antennae.each_value do |ants|
      ants.combination(2) do |pair|
        find_antinodes(pair[0], pair[1]).each do |a|
          @antinodes[a[0], a[1]] += 1
        end
      end
    end
  end

  def score
    count = 0
    @height.times do |y|
      @width.times do |x|
        count += 1 if @antinodes[y, x].positive?
      end
    end
    count
  end

  def inspect
    to_s
  end

  def to_s
    s  = "<#{self.class}:\n"
    @height.times do |y|
      @width.times do |x|
        if @map[y, x] != 0
          s << @map[y, x]
        elsif @antinodes[y, x] != 0
          s += '#'
        else
          s += '.'
        end
      end
      s += "\n"
    end
    s += ">"
    s
  end
end

map = Map.new File.read('08.input').lines.map(&:strip)
map.fill!
puts map.score
