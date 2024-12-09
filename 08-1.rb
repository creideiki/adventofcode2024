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
    possibles = [
      [
        a[0] + (b[0] - a[0]) * 2,
        a[1] + (b[1] - a[1]) * 2
      ],
      [
        b[0] + (a[0] - b[0]) * 2,
        b[1] + (a[1] - b[1]) * 2
      ]
    ]

    possibles.reject { |p| p[0] < 0 || p[0] >= @height || p[1] < 0 || p[1] >= @width }
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
