module RubyBBCode
  # As you parse a string of text, say:
  #     "[b]I'm bold and the next word is [i]ITALLICS[/i][b]"
  # ...you build up a tree of nodes (@bbtree).  The above string converts to 4 nodes when the parse has completed.
  # Node 1)  An opening tag node representing "[b]"
  # Node 2)  A text node         representing "I'm bold and the next word is "
  # Node 3)  An opening tag node representing "[i]"
  # Node 4)  A text node         representing "ITALLICS"
  #
  # The closing of the nodes seems to be implied which is fine by me --less to keep track of.  
  #  
  class BBTree
    attr_accessor :current_node, :tags_list
    
    def initialize(hash = {}, dictionary)
      @bbtree = hash
      @current_node = TagNode.new(@bbtree)
      @tags_list = []
      @dictionary = dictionary
    end
    
    def [](key)
      @bbtree[key]
    end
    
    def []=(key, value)
      @bbtree[key] = value
    end
    
    def within_open_tag?
      @tags_list.length > 0
    end
    alias :expecting_a_closing_tag? :within_open_tag?  # just giving this method multiple names for semantical purposes
    
    def parent_tag
      return nil if !within_open_tag?
      @tags_list.last.to_sym
    end
    
    def parent_has_constraints_on_children?
      @dictionary[parent_tag][:only_allow] != nil
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
    
  end
end