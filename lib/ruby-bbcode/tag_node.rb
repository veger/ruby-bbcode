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
      return false if type == :text or children.length == 0  # text nodes return false too
      return true if children.length > 0
    end

    def allow_tag_param?
      definition[:allow_tag_param]
    end

    # shows the tag definition for this TagNode as defined in tags.rb
    def definition
      @element[:definition]
    end

    def children
      @element[:nodes]
    end

    # Easy way to set the tag_param value of the hash, which represents
    # the parameter supplied
    def tag_param=(param)
      @element[:params] = {:tag_param => param}
    end

  end
end