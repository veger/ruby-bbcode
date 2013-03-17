module RubyBBCode
  def self.log(string, clear_file = false)
    clear_log_file_at_beginning_of_execution
    
    
    File.open('/tmp/ruby-bbcode.log', 'a') do |f|
      f.puts string
    end
  end
  
  def self.clear_log_file_at_beginning_of_execution
    if defined?(@@cleared_file).nil?
      @@cleared_file = true
      File.open('/tmp/ruby-bbcode.log', 'w+') do |f|
        puts ''
      end
    end
  end
  
end