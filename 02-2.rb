#!/usr/bin/env ruby

class Report
  attr_accessor :levels, :differences

  def initialize(line)
    @levels = line.split.map(&:to_i)
  end

  def safe_levels?(levels)
    differences = []
    (levels.size - 1).times do |i|
      differences << levels[i + 1] - levels[i]
    end

    return false unless differences.all?(&:negative?) or differences.all?(&:positive?)

    differences.all? { |d| d.abs >= 1 and d.abs <= 3 }
  end

  def safe?
    return true if safe_levels? @levels

    levels.combination(levels.size - 1).any? { |l| safe_levels? l }
  end
end

lines = File.read('02.input').lines.map(&:strip)

puts lines.count { |line| Report.new(line).safe? }
