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
      
      # I have a stacking problem....
      # The @bbtree contains a current_node which I suppose should be of the type TagNode, OR just a plain hash...
      # But during the retrogress process, sometimes the @bbtree get's written to the @current_node... thus current node is of the type
      # BBTree.......  
      @current_node = TagNode.new({:nodes => []})
      @tags_list = []
      @definition = nil
    end
    
    def [](key)
      @bbtree[key]
    end
    
    def []=(key, value)
      #binding.pry
      @bbtree[key] = value
    end
    
    def tags_list
      @tags_list
    end
    
    # Advance to next level (the node we just added)
    def escalate_bbtree(element)
      @tags_list.push element[:tag]
      @current_node = TagNode.new(element)
    end
    
    # Step down the bbtree a notch because we've reached a closing tag
    def retrogress_bbtree
      @tags_list.pop     # remove latest tag in tags_list since it's closed now... where's the manifestation of the parsed data go???

      # Since we just stepped down we should set the current node to be the @bbtree...
      # This works because the @bbtree includes everything except for the currently open node (which is being worked on)
      # ...But where does the node get stored...  
      @current_node = TagNode.new(@bbtree) # Set current_node to be the whole @bbtree
      
      if within_open_tag?
        # Set the current node to be the node we've just parsed over which is infact within another node??...
        @current_node = TagNode.new(@current_node[:nodes].last)
      else # if we're still at the root of the BBTree or have returned to the root via encountring closing tags...
        @current_node = TagNode.new(@bbtree)
      end
      

    end
    
    attr_accessor :current_node
    #def current_node
    #  @current_node
    #end
    
    def parent_tag
      return nil if @tags_list.last.nil?
      @tags_list.last.to_sym
    end
    
    # This method might never be needed for anything other than determining within_open_tag?
    def depth
      @tags_list.length
    end
    
    def within_open_tag?
      @tags_list.length > 0
    end
    
    def definition
      
    end
    
  end
end