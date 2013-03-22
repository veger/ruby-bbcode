module RubyBBCode
  def self.log(string, clear_file = true)
    clear_log_file_at_beginning_of_execution clear_file
    
    
    File.open('/tmp/ruby-bbcode.log', 'a') do |f|
      f.puts string
    end
  end
  
  def self.clear_log_file_at_beginning_of_execution(clear_file)
    return if !clear_file
    if defined?(@@cleared_file).nil?
      @@cleared_file = true
      File.open('/tmp/ruby-bbcode.log', 'w+') do |f|
        puts ''
      end
    end
  end
  
  
  module DebugBBTree
    def count_child_nodes(hash = @bbtree[:nodes], q = 0)
      #count = cycle_through_nodes(hash)
      #count += 1
      @@q = 1
      cycle_through_nodes(hash, q)
    end
    
    # I'd like for this function to output the tree in an indented fashion...
    # So for the text:  "[ol][li][b][/b]item 1[/li][li]item 2[/li][/ol]"
    # ...we would see:
    #  ol
    #    li
    #      b
    #      b
    #      b
    #      "item 1"
    #    li
    #      "item 2"
    # 
    def cycle_through_nodes(hash = @bbtree[:nodes], q = 0)
      i = 0
      #binding.pry
      hash.each.with_index do |node, j|
        
        a = [@@q, node[:tag]]
        #binding.pry if j == 0
        
        RubyBBCode.log "#{@@q}#{'  ' * @@q}" + hash[j].to_v + "\n"
        
        i += 1
        
        #q -= 2 if node.type == :text or node[:nodes].nil?    # has_no_child_nodes
        
        case node.type
        when :text           # hash[j][:nodes].nil?
          #q -= 1
          #next               # should NOT run the count_child_nodes method on it since it don't got no :nodes
        when :tag            # aka !hash[j].nil? and !hash[j][:nodes].nil?
          if !hash[j].nil?
            #q += 1 unless node[:tag].nil?
            #binding.pry if node[:tag] == :b
            @@q += 1 if j == 0
            count = cycle_through_nodes(hash[j][:nodes], @@q)
            if !hash[j][:nodes].nil?  # This following expression should really be the only condition... and 
              #binding.pry
              
            end
            @@q -= 1 if hash.length == (j+1)
            i += count
            #q += count
          end
        end
        
        @@q -= 1 if hash.length == (j+1)
        
      end
      
      return i
    end
  end
  
end