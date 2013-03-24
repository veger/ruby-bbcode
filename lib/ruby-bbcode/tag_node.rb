module RubyBBCode
  # Tag nodes are nodes that are stored up in the BBTree's @current_node[:nodes] array I think... which is a bit misleading... 
  # hey, maybe that can be factored out into it's own instance variable...
  # ... Ok, i've done some investigation, and it seems that at the end of process_text,
  #    @tag_sifter.bbtree[:nodes] == @tag_sifter.bbtree.current_node[:nodes]
  # I don't even get how that is... TODO:  Get to bottom of this...
  # When is @bbtree set to @current_node?
  # OOOHHH!  It happens that @current_node get's set to be @bbtree during the BBTree#retrogress_bbtree stage...
  #
  # They specify either opening tag elements or text elements...  TagInfo elements are essentially converted into these nodes which are
  # later converted into html output in the bbtree_to_html method
  class TagNode
    include RubyBBCode::DebugBBTree   # this is for debugging the class.  Check lib/debugging.rb
    attr_accessor :element #, :manifestation
    def initialize(element, nodes = [])
      @element = element    # { :is_tag=>false, :text=>"ITALLICS" } ||   { :is_tag=>true, :tag=>:i, :nodes => [] }
      @manifestation = nodes
      #@nodes = []  # TagNodes can contain other TagNodes as they rest in the BBTree
      # @current_node...  TagNodes shouldn't have @current_nodes... That's something only the BBTree has.  But
      # sometimes TagNodes get set directly to the BBTree I fear... this behavior must be changed before this 
      # class can be implemented.  TODO...
    end
    
    def [](key)
      @element[key]
    end
    
    def []=(key, value)
      @element[key] = value
    end
    
    # Debugging/ visualization purposes
    def type
      return :tag if @element[:is_tag]
      return :text if !@element[:is_tag]
    end
    
    # Checks to see if the parameter for the TagNode has been set.  
    def param_not_set?
      (@element[:params].nil? or @element[:params][:tag_param].nil?)
    end
    
    # shows the tag definition for this TagNode as defined in tags.rb
    def definition
      @element[:definition]
    end
    
    # Easy way to set the tag_param value of the hash, which represents 
    # the parameter supplied
    def tag_param=(param)
      @element[:params] = {:tag_param => param}
    end
    
    # Debugging/ visualization purposes
    #def to_v
    #  filtered = @element.reject {|el| el == :definition}
    #  filtered = filtered.reject {|el| el == :nodes}
    #  (filtered.pretty_inspect + "")
    #end
    
    # uncomment this to prevent the tags from smearing up the debug console like a crash dump
=begin
    def to_s
      if self[:is_tag]
        child_nodes = "#{self[:nodes]}"
        #return "#{self[:tag].to_s}, #{child_nodes}"
        return "#{self[:tag].to_s}:#{self[:nodes].count}" #+ ", Children: #{child_nodes.count}"
      else
        return '"' + self[:text].to_s + '"'
      end
      
    end
=end

  end
end