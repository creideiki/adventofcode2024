#!/usr/bin/env ruby

require 'numo/narray'

class Robot
  attr_accessor :x, :y, :vx, :vy

  def initialize(line, width, height)
    @width = width
    @height = height

    p, v = line.split
    @x, @y = p[2..].split(',').map(&:to_i)
    @vx, @vy = v[2..].split(',').map(&:to_i)
  end

  def step!
    @x = (@x + @vx) % @width
    @y = (@y + @vy) % @height
  end
end

class Map
  attr_reader :map, :regions

  def initialize(lines)
    @height = 103
    @width = 101
    @robots = lines.map { |l| Robot.new(l, @width, @height) }
  end

  def step!
    @robots.each &:step!
  end

  def score
    safety = 1

    quadrants = Hash.new 0

    @robots.each do |r|
      if r.y <= (@height / 2 - 1) and
         r.x <= (@width / 2 - 1)
        quadrants[:upper_left] += 1
      elsif r.y <= (@height / 2 - 1) and
            r.x >= (@width / 2 + 1)
        quadrants[:lower_left] += 1
      elsif r.y >= (@height / 2 + 1) and
            r.x <= (@width / 2 - 1)
        quadrants[:upper_right] += 1
      elsif r.y >= (@height / 2 + 1) and
            r.x >= (@width / 2 + 1)
        quadrants[:lower_right] += 1
      end
    end

    quadrants.values.reduce &:*
  end

  def inspect
    to_s
  end

  def to_s
    map = Numo::UInt8.zeros(@height, @width)
    @robots.each do |r|
      map[r.y, r.x] += 1
    end

    s = "<#{self.class}:\n"
    @height.times do |y|
      @width.times do |x|
        s += if map[y, x].zero?
               '.'
             else
               map[y, x].to_s
             end
      end
      s += "\n"
    end
    s += '>'
    s
  end
end

map = Map.new File.read('14.input').lines.map(&:strip)
100.times { map.step! }
puts map.score
