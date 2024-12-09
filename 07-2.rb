#!/usr/bin/env ruby

class Formula
  attr_reader :possible, :value

  def initialize(line)
    val, terms = line.split ':'
    @value = val.to_i
    @terms = terms.split.map(&:to_i)
    @opers = nil
    @possible = nil
  end

  def solve_tail(result, partial, opers, terms)
    return nil if partial > result
    return opers if result == partial && terms.empty?
    return nil if terms.empty?

    term = terms[0]

    solution = solve_tail(result, partial + term, opers + [:+], terms[1..])
    return solution if solution

    solution = solve_tail(result, partial * term, opers + [:*], terms[1..])
    return solution if solution

    solve_tail(result, partial * 10.pow(Math.log10(term).floor + 1) + term, opers + [:|], terms[1..])
  end

  def solve!
    @opers = solve_tail(@value, @terms[0], [], @terms[1..])
    @possible = !@opers.nil?
  end

  def inspect
    to_s
  end

  def to_s
    s  = "<#{self.class}: #{@value} = "
    if @opers.nil?
      s += @terms.to_s
    else
      @opers.each_index do |i|
        s += "#{@terms[i]} #{@opers[i]} "
      end
      s += @terms[-1].to_s
    end
    s += " #{@possible}" unless @possible.nil?
    s += '>'
    s
  end
end

lines = File.read('07.input').lines.map(&:strip)
formulae = lines.map { |l| Formula.new l }
formulae.map(&:solve!)
puts formulae.select(&:possible).map(&:value).sum
