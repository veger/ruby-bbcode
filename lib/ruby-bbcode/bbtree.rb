module RubyBBCode
  # As you parse a string of text, say:
  #     "[b]I'm bold and the next word is [i]ITALLICS[/i][b]"
  # ...you build up a tree of nodes.  The above string converts to 2 nodes when it's completed the parse.
  # Node 1)  An opening tag node representing "[b]"
  # Node 2)  A text node         representing "I'm bold and the next word is "
  # Node 3)  An opening tag node representing "[i]"
  # Node 4)  A text node         representing "ITALLICS"
  #
  # The closing of the nodes seems to be implied which is fine by me --less to keep track of.  
  #  
  class BBTree
    def initialize(hash = {})
      @bbtree = hash
      @current_node = nil
      @tags_list = []
    end
    
    def [](key)
      @bbtree[key]
    end
    
    def []=(key, value)
      #binding.pry
      @bbtree[key] = value
    end
    
    def current_node
      
    end
    
    def depth
      @tags_list.length
    end
    
    def param_not_set?
      (@bbtree[:params].nil? or @bbtree[:params][:tag_param].nil?)
    end
    
    
    
  end
end