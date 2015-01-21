module RubyBBCode
  # A TagNode specifies either an opening tag element or a (plain) text elements
  #
  # TagInfo elements are essentially converted into these nodes which are
  # later converted into html output in the bbtree_to_html method
  class TagNode
    # Tag or text element that is stored in this node
    attr_accessor :element

    # ==== Attributes
    #
    # * +element+ - contains the information of TagInfo#tag_data.
    #   A text element has the form of
    #       { :is_tag=>false, :text=>"ITALIC" }
    #   and a tag element has the form of
    #       { :is_tag=>true, :tag=>:i, :nodes => [] }
    # * +nodes+
    def initialize(element, nodes = [])
      @element = element
    end

    def [](key)
      @element[key]
    end

    def []=(key, value)
      @element[key] = value
    end

    # Returns :tag is the node is a tag node, and :text if the node is a text node
    def type
      @element[:is_tag] ? :tag : :text
    end

    # Returns true if the tag is allowed to have parameters
    def allow_params?
      definition[:param_tokens]
    end

    # Returns true if the tag does not have any parameters set.
    def params_not_set?
      @element[:params].length == 0
    end

    # Returns true if the tag has any parameters set.
    def params_set?
      @element[:params].length > 0
    end

    # Returns true id the node that child nodes
    def has_children?
      type == :tag and children.length > 0
    end

    # shows the tag definition for this TagNode as defined in tags.rb
    def definition
      @element[:definition]
    end

    # Return an list containing the child nodes of this node.
    def children
      @element[:nodes]
    end
  end
end