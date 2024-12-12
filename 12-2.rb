#!/usr/bin/env ruby

require 'numo/narray'

class Edge
  attr_reader :from, :to, :dir

  def initialize(from, to, dir)
    @from = from
    @to = to
    @dir = dir
  end

  def adjacent?(other)
    @dir == other.dir and
      (@from == other.to or
       @to == other.from)
  end

  def merge(other)
    if @dir != other.dir
      raise "Merging edges of different directions: #{this}, #{other}"
    elsif @from == other.to
      Edge.new(other.from, @to, @dir)
    elsif @to == other.from
      Edge.new(@from, other.to, @dir)
    else
      raise "Merging non-adjacent edges #{this}, #{other}"
    end
  end

  def inspect
    to_s
  end

  def to_s
    "<#{self.class}: #{@from} -> #{@to} #{@dir}>"
  end
end

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

  def edges(region)
    edges = []
    region.map do |plot|
      y, x = plot

      edges << Edge.new([y, x], [y, x + 1], :right) unless region.include? [plot[0] - 1, plot[1]]
      edges << Edge.new([y + 1, x], [y + 1, x + 1], :left) unless region.include? [plot[0] + 1, plot[1]]
      edges << Edge.new([y, x], [y + 1, x], :up) unless region.include? [plot[0], plot[1] - 1]
      edges << Edge.new([y, x + 1], [y + 1, x + 1], :down) unless region.include? [plot[0], plot[1] + 1]
    end
    edges
  end

  def merge_sides!(edges)
    loop do
      catch :restart do
        edges.each_index do |i1|
          (i1 + 1).upto(edges.size - 1) do |i2|
            if edges[i1].adjacent? edges[i2]
              e1 = edges[i1]
              e2 = edges[i2]
              edges.delete_at i2
              edges.delete_at i1
              edges.insert(i1, e1.merge(e2))
              throw :restart
            end
          end
        end
        return edges
      end
    end
  end

  def score
    @regions.map do |region|
      sides = merge_sides!(edges(region))
      region.size * sides.size
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
