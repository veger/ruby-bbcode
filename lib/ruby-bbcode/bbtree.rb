module RubyBBCode
  # Tree of nodes containing the parsed BBCode information and the plain texts
  #
  # As you parse a string of text, say:
  #     "[b]I'm bold and the next word is [i]ITALIC[/i][b]"
  # ...you build up a tree of nodes (@bbtree).  The above string is represented by 4 nodes when parsing has completed.
  # * Node 1)  An opening tag node representing "[b]"
  # * Node 2)  A text node         representing "I'm bold and the next word is "
  # * Node 3)  An opening tag node representing "[i]"
  # * Node 4)  A text node         representing "ITALIC"
  #
  class BBTree
    attr_accessor :current_node, :tags_list

    def initialize(hash = { :nodes => TagCollection.new })
      @bbtree = hash
      @current_node = TagNode.new(@bbtree)
      @tags_list = []
    end

    def [](key)
      @bbtree[key]
    end

    def []=(key, value)
      @bbtree[key] = value
    end

    def nodes
      @bbtree[:nodes]
    end

    def type
      :bbtree
    end

    def within_open_tag?
      @tags_list.length > 0
    end
    alias :expecting_a_closing_tag? :within_open_tag?  # just giving this method multiple names for semantical purposes

    # Returns the parent tag, if suitable/available
    def parent_tag
      return nil unless within_open_tag?
      @tags_list.last
    end

    # Return true if the parent tag only allows certain child tags
    def parent_has_constraints_on_children?
      parent_tag[:definition][:only_allow] != nil
    end

    # Advance to next level (the node we just added)
    def escalate_bbtree(element)
      @current_node = TagNode.new(element)
      @tags_list.push @current_node
    end

    # Step down the bbtree a notch because we've reached a closing tag
    def retrogress_bbtree
      @tags_list.pop     # remove latest tag in tags_list since it's closed now...
      # The parsed data manifests in @bbtree.current_node.children << TagNode.new(element) which I think is more confusing than needed

      if within_open_tag?
        # Set the current node to be the node we've just parsed over which is infact within another node??...
        @current_node = TagNode.new(self.nodes.last)
      else # If we're still at the root of the BBTree or have returned back to the root via encountring closing tags...
        @current_node = TagNode.new({:nodes => self.nodes})  # Note:  just passing in self works too...
      end
    end

    # Handle parent tag as regular text (i.e. the tag is probably not recognized)
    def redefine_parent_tag_as_text
      @tags_list.pop
      @current_node[:is_tag] = false
      @current_node[:closing_tag] = false
      @current_node.element[:text] = "[#{@current_node[:tag]}]"
    end

    # Create a new node and adds it to the current node as a child node
    def build_up_new_tag(element)
      @current_node.children << TagNode.new(element)
    end

    def to_html(tags = {})
      self.nodes.to_html(tags)
    end

    def to_bbcode(tags = {})
      self.nodes.to_bbcode(tags)
    end
  end
end
