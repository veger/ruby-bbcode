require 'test_helper'
require 'benchmark'



class RubyBbcodeTest < Test::Unit::TestCase

  # TODO:  This stack level problem should be validated during the validations
  def test_stack_level_too_deep
    num = 2300  # increase this number if the test starts failing.  It's very near the tipping point
    openers = "[s]hi i'm" * num
    closers = "[/s]" * num
    #assert_raise( SystemStackError ) do
      (openers+closers).bbcode_to_html
    #end
    
  end
  
=begin
  def test_speed
    num = 1000
    openers = "[s]hi i'm [s]" * num
    closers = "[/s][/s]" * num
    
    times = []
    40.times do |i|
      times[i] = Benchmark.measure do
        (openers+closers).bbcode_to_html
      end
    end

    avg = 0
    times.each do |t|
      avg += t.real
    end
    avg = avg/times.length
    
    puts "Avg Time:  #{avg}"
  end
=end
  
=begin
  def test_memory_usage
    num = 1000
    openers = "[s]hi i'm [s]" * num
    closers = "[/s][/s]" * num
    megastring = openers+closers
    
    GC.start
    mem1 = get_current_memory_usage
    GC.start
    
    megastring.bbcode_to_html
    mem2 = get_current_memory_usage
    GC.start
    
    megastring.bbcode_to_html
    mem3 = get_current_memory_usage
    
    puts "mem1:  #{mem1}"
    puts "mem2:  #{mem2}"
    puts "mem3:  #{mem3}"
  end
=end
  
end