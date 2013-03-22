module RubyBBCode
  def self.log(string)
    File.open('/tmp/ruby-bbcode.log', 'a') do |f|
      f.puts string
    end
  end
end