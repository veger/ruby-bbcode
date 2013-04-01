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
  
  
  # This module can be included in the BBTree and TagNode to give them debugging features
  module DebugBBTree
    # For Debugging/ visualization purposes.
    # This can be used to render the [:nodes] array in a pretty manor, showing the hirarchy.  
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
    
    
    # this blocky method counts how many children are
    # in the TagNode[:nodes], recursively walking the tree
    def count_child_nodes(hash = self[:nodes])
      count = 0
      walk_tree(hash) do
        count += 1
      end
      count
    end

    def to_s
      object_identifier = "#<#{self.class.to_s}:0x#{'%x' % (self.object_id << 1)}\n"
      close_object = ">\n"
      
      case self
      when RubyBBCode::BBTree
        object_identifier + "Children: #{count_child_nodes}\n" + self.to_v + close_object
      when RubyBBCode::TagNode   # when inspecting TagNodes, it's better not to show the tree display
        if self[:is_tag]
          object_identifier + "Tag:  #{self[:tag].to_s}, Children: #{count_child_nodes}\n" + close_object
        else
          object_identifier + '"' + self[:text].to_s + "\"\n" + close_object
        end
      end
    end
    
    private
    
    # This function is used by to_v and anything else that needs to iterate through the 
    # @bbtree
    def walk_tree(tree, depth = -1, &blk)
      return enum_for(:walk_tree) unless blk  # ignore me for now, I'm a convention for being versatile
      
      # Perform the block action specified at top level!!!
      yield tree, depth unless depth == -1
      
      # next if we're a text node
      begin
        return if tree[:nodes].nil? or tree[:nodes].empty?
        nodes = tree[:nodes]
      rescue
        nodes = tree    # this rescue got hacked in to extend the walk_tree method to work for counting children...
      end
      
      # Enter into recursion (including block action) for each child node in this node
      nodes.each do |node|
        children = node[:nodes].nil? ? nil : node[:nodes].count
        walk_tree(node, depth + 1, &blk)
      end
    end
    
  end
  
end