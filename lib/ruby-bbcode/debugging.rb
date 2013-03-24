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
    # Debugging/ visualization purposes
    def to_v
      tree ||= @bbtree.nil? ? @element : @bbtree # this function works for both BBTree and also TagNodes
      manifestation = ''
      
      walk_tree(tree) do |node, depth|
        indentation = '  ' * depth
        case node[:is_tag]
        when true
          manifestation += "#{indentation}" + node[:tag].to_s + "\n"
        when false
          manifestation += "#{indentation}\"#{node[:text]}\"\n"
        end
      end
      
      manifestation
    end
    
    def walk_tree(tree, depth = -1, &blk)
      return enum_for(:walk_tree) unless blk  # ignore me for now, I'm a convention for being versatile
      
      # Perform the block action specified at top level!!!
      yield tree, depth unless depth == -1
      
      # next if we're a text node
      return if tree[:nodes].nil? or tree[:nodes].empty?
      
      # Enter into recursion (including block action) for each child node in this node
      tree[:nodes].each do |node|
        children = node[:nodes].nil? ? nil : node[:nodes].count
        walk_tree(node, depth + 1, &blk)
      end
    end
    
    
    

    
    
    def count_child_nodes(hash = @bbtree[:nodes])
      cycle_through_nodes(hash)
    end
    
    def cycle_through_nodes(hash = @bbtree[:nodes])
      i = 0
      hash.each.with_index do |node, j|
        i += 1
        
        case node.type
        when :text
          #next
        when :tag
          if !hash[j].nil?
            count = cycle_through_nodes(hash[j][:nodes])
            i += count
          end
        end
        
      end
      
      return i
    end
    
  end
  
end