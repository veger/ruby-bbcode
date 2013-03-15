module RubyBBCode
  # Tag nodes are nodes that are placed in the BBTree collection.  
  # They specify either opening tag elements or text elements...  But that's what TagInfos do... It's just that TagInfo elements... are just discarded...
  
  # Pass in a hash...  It acts as a hash... but has a single cool method...
  class TagNode
    def initialize(element)
      @element = element    # { :is_tag=>false, :text=>"ITALLICS" } ||   { :is_tag=>true, :tag=>:i, :nodes => [] }
      #@nodes = []  # TagNodes can contain other TagNodes as they rest in the BBTree
      # @current_node...  TagNodes shouldn't have @current_nodes... That's something only the BBTree has.  But
      # sometimes TagNodes get set directly to the BBTree I fear... this behavior must be changed before this 
      # class can be implemented.  TODO...
    end
    
    def [](key)
      @element[key]
    end
    
    def []=(key, value)
      #binding.pry
      @element[key] = value
    end
    
    # ... this is incomplete.....
    def param_not_set?
      (@element[:params].nil? or @element[:params][:tag_param].nil?)
    end
  end
end