#!/usr/bin/env ruby

require 'numo/narray'
require 'parallel'
require 'progressbar'

class Map
  attr_reader :height, :width, :map, :init_guard_x, :init_guard_y, :init_guard_dir

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
          @init_guard_y = @guard_y = y
          @init_guard_x = @guard_x = x
          @init_guard_dir = @guard_dir = :north
        end
      end
    end
  end

  def initialize_copy(other)
    @height = other.height
    @width = other.width
    @map = other.map.clone
    @init_guard_x = @guard_x = other.init_guard_x
    @init_guard_y = @guard_y = other.init_guard_y
    @init_guard_dir = @guard_dir = other.init_guard_dir
  end

  def reset!
    @guard_y = @init_guard_y
    @guard_x = @init_guard_x
    @guard_dir = @init_guard_dir
  end

  def add_obstacle(y, x)
    @map[y, x] = 1
  end

  def walk!
    visited = []

    res = :again
    while res == :again
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

      if visited.include? [@guard_y, @guard_x, @guard_dir]
        res = :loop
        break
      end

      visited << [@guard_y, @guard_x, @guard_dir]

      if next_x < 0 or next_x >= @width or
         next_y < 0 or next_y >= @height
        @guard_x = next_x
        @guard_y = next_y
        res = :leave
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
        res = :again
      else
        @map[next_y, next_x] = 2
        @guard_x = next_x
        @guard_y = next_y
        res = :again
      end
    end

    if res == :loop
      1
    elsif res == :leave
      0
    end
  end

  def route
    route = []
    @height.times do |y|
      @width.times do |x|
        route << [y, x] if @map[y, x] == 2
      end
    end
    route
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
map.walk!

puts(Parallel.map(map.route, progress: 'Solving') do |candidate_obstacle|
  simulation = map.clone
  simulation.reset!
  simulation.add_obstacle(candidate_obstacle[0], candidate_obstacle[1])
  simulation.walk!
end.sum)
