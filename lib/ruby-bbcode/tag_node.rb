module RubyBBCode
  # TagNodes are nodes that are stored up in the BBTree's @current_node[:nodes] array I think... which is a bit misleading... 
  #
  # TagNodes specify either opening tag elements or text elements...  TagInfo elements are essentially converted into these nodes which are
  # later converted into html output in the bbtree_to_html method
  class TagNode
    attr_accessor :element
    
    def initialize(element, nodes = [])
      @element = element    # { :is_tag=>false, :text=>"ITALLICS" } ||   { :is_tag=>true, :tag=>:i, :nodes => [] }
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
    
    # check if the parameter for the TagNode is set
    def param_set?
      !param_not_set?
    end
    
    def has_children?
      @element[:nodes].length > 0
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