#!/usr/bin/env ruby

require 'ostruct'

class Disk
  attr_reader :runs

  def initialize(map)
    @runs = []
    file_num = 0
    block_num = 0
    map.size.times do |i|
      next if map[i].to_i.zero?

      if i.even?
        run = OpenStruct.new
        run.type = :file
        run.base = block_num
        run.length = map[i].to_i
        run.file_num = file_num

        block_num += run.length

        @runs << run

        file_num += 1
      else
        run = OpenStruct.new
        run.type = :empty
        run.base = block_num
        run.length = map[i].to_i

        block_num += run.length

        @runs << run
      end
    end
    @last_file_num = file_num - 1
  end

  def find_first_free_index(size)
    @runs.index { |r| r.type == :empty && r.length >= size}
  end

  def find_file_index(file_num)
    @runs.rindex { |r| r.type == :file && r.file_num == file_num }
  end

  def compact_one_run!(free_index, file_index)
    free = @runs[free_index]
    file = @runs[file_index]
    size = file.length

    run = OpenStruct.new
    run.type = :file
    run.base = free.base
    run.length = size
    run.file_num = file.file_num

    free.length -= size
    free.base += size

    @runs.insert(free_index, run)
    free_index += 1
    file_index += 1

    if free.length.zero?
      @runs.delete_at(free_index)
      file_index -= 1
    end

    file.type = :empty
  end

  def compact!
    @last_file_num.downto(0) do |file_num|
      file_index = find_file_index file_num
      free_index = find_first_free_index @runs[file_index].length

      next unless free_index
      next if free_index > file_index

      compact_one_run!(free_index, file_index)
    end
  end

  def checksum
    score = 0
    index = 0
    @runs.each do |r|
      if r.type == :empty
        index += r.length
        next
      else
        index.upto(index + r.length - 1) do |i|
          score += i * r.file_num
        end
        index += r.length
      end
    end
    score
  end

  def inspect
    to_s
  end

  def to_s
    s = "<#{self.class}: "
    @runs.each do |r|
      s += case r.type
           when :file
             r.file_num.to_s
           when :empty
             '.'
           end * r.length
    end
    s += '>'
    s
  end
end

disk = Disk.new File.read('09.input').strip
disk.compact!
puts disk.checksum
