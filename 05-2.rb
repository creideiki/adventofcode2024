#!/usr/bin/env ruby

class Rule
  attr_reader :from, :to

  def initialize(line)
    @from, @to = line.split('|').map(&:to_i)
  end

  def inspect
    to_s
  end

  def to_s
    "<#{self.class}: #{@from} -> #{@to}>"
  end
end

class Update
  attr_reader :pages

  def initialize(line, rules)
    @pages = line.split(',').map(&:to_i)
    @rules = rules
  end

  def satisfy?(rule)
    first = @pages.find_index rule.from
    last = @pages.find_index rule.to

    return true if first.nil? or last.nil?

    first < last
  end

  def sort!
    @pages.sort! do |a, b|
      if @rules.any? { |r| r.from == a and r.to == b }
        -1
      elsif @rules.any? { |r| r.from == b and r.to == a }
        1
      else
        0
      end
    end
  end

  def score
    @pages[@pages.size / 2]
  end

  def inspect
    to_s
  end

  def to_s
    "<#{self.class}: #{@pages}>"
  end
end

class Puzzle
  def initialize(input)
    rules, updates = input.partition { |l| l.include? '|' }

    @rules = rules.map { |r| Rule.new r }
    @updates = updates.reject { |u| u == '' }.map { |u| Update.new(u, @rules) }
  end

  def score
    @updates.map do |u|
      if not @rules.all? { |r| u.satisfy? r }
        u.sort!
        u.score
      else
        0
      end
    end.sum
  end
end

input = File.read('05.input').lines.map(&:strip)
puzzle = Puzzle.new(input)
puts puzzle.score
