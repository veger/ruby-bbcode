module RubyBBCode
  # Tag nodes are nodes that are stored up in the BBTree's @current_node[:nodes] array I think... which is a bit misleading... 
  # hey, maybe that can be factored out into it's own instance variable 
  #
  # They specify either opening tag elements or text elements...  TagInfo elements are essentially converted into these nodes which are
  # later converted into html output in the bbtree_to_html method
  class TagNode
    attr_accessor :manifestation
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
  end
end