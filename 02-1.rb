#!/usr/bin/env ruby

class Report
  attr_accessor :levels, :differences

  def initialize(line)
    @levels = line.split.map(&:to_i)
    gen_differences
  end

  def gen_differences
    @differences = []
    (@levels.size - 1).times do |i|
      @differences << @levels[i + 1] - @levels[i]
    end
  end

  def safe?
    return false unless @differences.all?(&:negative?) or @differences.all?(&:positive?)

    @differences.all? { |d| d.abs >= 1 and d.abs <= 3 }
  end
end

lines = File.read('02.input').lines.map(&:strip)

puts lines.count { |line| Report.new(line).safe? }
