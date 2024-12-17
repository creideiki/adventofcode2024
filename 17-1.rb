#!/usr/bin/env ruby

class CPU
  attr_accessor :ip, :regs, :output

  def initialize
    @regs = {}
    @ip = 0
    @output = []
  end

  def load_reg(reg, value)
    @regs[reg] = value
  end

  def load_program(program)
    @program = program
  end

  def combo(op)
    case op
    when 0..3
      op
    when 4
      @regs[:a]
    when 5
      @regs[:b]
    when 6
      @regs[:c]
    when 7
      raise 'Illegal combo operator'
    end
  end

  def step!
    return :halt if @ip >= @program.size

    insn = @program[@ip]
    @ip += 1
    op = @program[@ip]
    @ip += 1
    case insn
    when 0 # adv
      @regs[:a] = @regs[:a] / 2.pow(combo(op))
    when 1 # bxl
      @regs[:b] = @regs[:b] ^ op
    when 2 # bst
      @regs[:b] = combo(op) % 8
    when 3 # jnz
      return if @regs[:a].zero?
      @ip = op
    when 4 # bxc
      @regs[:b] = @regs[:b] ^ @regs[:c]
    when 5 # out
      @output << combo(op) % 8
    when 6 # bdv
      @regs[:b] = @regs[:a] / 2.pow(combo(op))
    when 7 # cdv
      @regs[:c] = @regs[:a] / 2.pow(combo(op))
    end
  end
end

reg_format = /^Register (?<reg>[[:alpha:]]): (?<val>[[:digit:]]+)$/
prog_format = /^Program: (?<insns>[,[:digit:]]+)$/

input = File.read('17.input').lines.map(&:strip)

cpu = CPU.new

until (line = input.shift).empty?
  m = reg_format.match line
  cpu.load_reg(m['reg'].downcase.to_sym, m['val'].to_i)
end

m = prog_format.match input.shift
cpu.load_program m['insns'].split(',').map(&:to_i)

until cpu.step! == :halt
end

puts cpu.output.join ','
