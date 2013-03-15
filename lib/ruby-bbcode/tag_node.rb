module RubyBBCode
  # Tag nodes are nodes that are placed in the BBTree collection.  
  # They specify either opening tag elements or text elements.  
  class TagNode
    def initialize(element)
      @element = nil    # { :is_tag=>false, :text=>"ITALLICS" } ||   { :is_tag=>true, :tag=>:i, :nodes => [] }
      @nodes = []  # TagNodes can contain other TagNodes as they rest in the BBTree
      # @current_node...  TagNodes shouldn't have @current_nodes... That's something only the BBTree has.  But
      # sometimes TagNodes get set directly to the BBTree I fear... this behavior must be changed before this 
      # class can be implemented.  TODO...
    end
  end
end