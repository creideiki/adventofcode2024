#!/usr/bin/env ruby

require 'numo/narray'

class Map
  attr_reader :map, :regions

  def initialize(input)
    @height = input.size
    @width = input[0].size
    @map = Numo::UInt8.zeros(@height, @width)
    @height.times do |y|
      @width.times do |x|
        @map[y, x] = input[y][x].codepoints[0]
      end
    end
    @handled = Numo::UInt8.zeros(@height, @width)
    @regions = nil
  end

  def flood_fill!(y, x)
    plant = @map[y, x]
    region = []
    queue = [[y, x]]
    until queue.empty?
      cell = queue.shift
      next unless @map[cell[0], cell[1]] == plant
      next unless @handled[cell[0], cell[1]].zero?

      region << cell
      @handled[cell[0], cell[1]] = 1

      queue << [cell[0] - 1, cell[1]] if cell[0] > 0
      queue << [cell[0] + 1, cell[1]] if cell[0] < (@height - 1)
      queue << [cell[0], cell[1] - 1] if cell[1] > 0
      queue << [cell[0], cell[1] + 1] if cell[1] < (@width - 1)
    end

    region
  end

  def split!
    @regions = []
    @height.times do |y|
      @width.times do |x|
        next if @handled[y, x] == 1

        @regions << flood_fill!(y, x)
      end
    end
  end

  def score
    @regions.map do |region|
      area = region.size
      perimeter = region.map do |plot|
        p = 0
        p += 1 unless region.include? [plot[0] - 1, plot[1]]
        p += 1 unless region.include? [plot[0] + 1, plot[1]]
        p += 1 unless region.include? [plot[0], plot[1] - 1]
        p += 1 unless region.include? [plot[0], plot[1] + 1]
        p
      end.sum
      area * perimeter
    end.sum
  end

  def inspect
    to_s
  end

  def to_s
    s = "<#{self.class}:\n"
    @height.times do |y|
      @width.times do |x|
        s << @map[y, x]
      end
      s += "\n"
    end
    s += "\nUsed:\n"
    @height.times do |y|
      @width.times do |x|
        s << case @handled[y, x]
             when 0
               '.'
             when 1
               '#'
             end
      end
      s += "\n"
    end
    s += "\n"
    s += "#{@regions.size} regions\n" if @regions
    s += '>'
    s
  end
end

map = Map.new File.read('12.input').lines.map(&:strip)
map.split!
puts map.score
