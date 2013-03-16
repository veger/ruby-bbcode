module RubyBBCode
  # TODO:  Rename to something cooler, like TagDetector or maybe TextTransmutor.  Or TagSifter
  class TagCollection
    attr_reader :bbtree, :errors
    
    def initialize(text_to_parse, dictionary)
      @text = text_to_parse
      @dictionary = dictionary # the dictionary for all the defined tags in tags.rb
      @bbtree = BBTree.new({:nodes => []}, dictionary)
      @ti = nil
      @errors = false
    end
    
    def invalid?
      @errors != false
    end
    
    
    def process_text
      regex_notes # This method doesn't do anything, I just have a few notes on the regex statement
      regex_string = '((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))'
      @text.scan(/#{regex_string}/ix) do |tag_info|
        @ti = TagInfo.new(tag_info, @dictionary)
        
        @ti.handle_unregistered_tags_as_text  # if the tag isn't in the @dictionary list, then treat it as text
        return if !valid_element?
        
        case @ti.type   # Validation of tag succeeded, add to @bbtree.tags_list and/or bbtree
        when :opening_tag
          element = {:is_tag => true, :tag => @ti[:tag].to_sym, :definition => @ti.definition, :nodes => [] }
          element[:params] = {:tag_param => @ti[:params][:tag_param]} if @ti.can_have_params? and @ti.has_params?
          @bbtree.current_node[:nodes] << TagNode.new(element)
          @bbtree.escalate_bbtree(element)
        when :text
          element = {:is_tag => false, :text => @ti.text }
          if within_open_tag?
            tag = @bbtree.current_node.definition
            if tag[:require_between]
              @bbtree.current_node[:between] = @ti[:text]
              if candidate_for_using_between_as_param?
                use_between_as_tag_param    # Did not specify tag_param, so use between text.
              end
              next  # don't add this node to @bbtree.current_node[:nodes] if we're within an open tag that requires_between (to be a param), and the between couldn't be used as a param... Yet it passed validation so the param must have been specified within the opening tag???
            end
          end
          @bbtree.current_node[:nodes] << TagNode.new(element)
        when :closing_tag
          @bbtree.retrogress_bbtree
        end
        
      end # end of scan loop
      
      validate_all_tags_closed_off
    end
    
    
    protected
    
    # Validates the element
    def valid_element?
      return false if !valid_text_or_opening_element?
      return false if !valid_closing_element?
      return false if !valid_param_supplied_as_text?
      true
    end
    
    def valid_text_or_opening_element?
      if @ti.element_is_text? or @ti.element_is_opening_tag?
        # TODO:  rename this if statement to #validate_opening_tag
        if @ti.element_is_opening_tag?
          unless @ti.allowed_outside_parent_tags? or (within_open_tag? and @ti.allowed_in(parent_tag.to_sym))
            # Tag doesn't belong in the last opened tag
            throw_child_requires_specific_parent_error; return false
          end
  
          # Originally:  tag[:allow_tag_param] and ti[:params][:tag_param] != nil
          if @ti.can_have_params? and @ti.has_params?
            # Test if matches
            if @ti.invalid_param?
              throw_invalid_param_error; return false
            end
          end
        end
        
        # TODO:  Rename this if statement to #validate_constraints_on_child
        if within_open_tag? and parent_has_constraints_on_children?
          # Check if the found tag is allowed
          last_tag = @dictionary[parent_tag]
          allowed_tags = last_tag[:only_allow]
          if (!@ti[:is_tag] and last_tag[:require_between] != true and @ti[:text].lstrip != "") or (@ti[:is_tag] and (allowed_tags.include?(@ti[:tag].to_sym) == false))  # TODO: refactor this, it's just too long
            # Last opened tag does not allow tag
            throw_parent_prohibits_this_child_error; return false
          end
        end
      end
      true
    end
    
    def valid_closing_element?
      tag = @ti.definition
      
      if @ti.element_is_closing_tag?
        if parent_tag != @ti[:tag].to_sym
          @errors = ["Closing tag [/#{@ti[:tag]}] does match [#{parent_tag}]"] 
          return false
        end
        
        if tag[:require_between] == true and @bbtree.current_node[:between].nil?
          @errors = ["No text between [#{@ti[:tag]}] and [/#{@ti[:tag]}] tags."]
          return false
        end
      end  
      true
    end
    
    # This validation is for text elements with between text 
    # that might be construed as a param.
    # The validation code checks if the params match constraints
    # imposed by the node/tag/parent.  
    def valid_param_supplied_as_text?
      tag = @bbtree.current_node.definition
      
      # this conditional ensures whether the validation is apropriate to this tag type
      if @ti.element_is_text? and within_open_tag? and tag[:require_between] and candidate_for_using_between_as_param?
      
        # check if valid
        if @ti[:text].match(tag[:tag_param]).nil?
          @errors = [tag[:tag_param_description].gsub('%param%', @ti[:text])]
          return false
        end
      end
      true
    end
    
    def validate_all_tags_closed_off
      # if we're still expecting a closing tag and we've come to the end of the string... throw error
      throw_unexpected_end_of_string_error if expecting_a_closing_tag?
    end
    
    def throw_child_requires_specific_parent_error
      err = "[#{@ti[:tag]}] can only be used in [#{@ti.definition[:only_in].to_sentence(to_sentence_bbcode_tags)}]"
      err += ", so using it in a [#{parent_tag}] tag is not allowed" if expecting_a_closing_tag?
      @errors = [err]
    end
    
    def throw_invalid_param_error
      @errors = [@ti.definition[:tag_param_description].gsub('%param%', @ti[:params][:tag_param])]
    end
    
    def throw_parent_prohibits_this_child_error
      allowed_tags = @dictionary[parent_tag][:only_allow]
      err = "[#{parent_tag}] can only contain [#{allowed_tags.to_sentence(to_sentence_bbcode_tags)}] tags, so "
      err += "[#{@ti[:tag]}]" if @ti[:is_tag]
      err += "\"#{@ti[:text]}\"" unless @ti[:is_tag]
      err += ' is not allowed'
      @errors = [err]
    end
    
    def throw_unexpected_end_of_string_error
      @errors = ["[#{@bbtree.tags_list.to_sentence(to_sentence_bbcode_tags)}] not closed"]
    end
    
    def to_sentence_bbcode_tags
      {:words_connector => "], [", 
        :two_words_connector => "] and [", 
        :last_word_connector => "] and ["}
    end
    
    
    def expecting_a_closing_tag?
      @bbtree.expecting_a_closing_tag?
    end
    
    def use_between_as_tag_param
      @bbtree.current_node.tag_param = @ti[:text]      # @bbtree.current_node[:params] = {:tag_param => @ti[:text]}
    end
    
    def candidate_for_using_between_as_param?
      # TODO:  the bool values... 
      # are unclear and should be worked on.  Additional tag might be tag[:requires_param] such that
      # [img] would have that as true...  and [url] would have that as well...  
      # as it is now, if a tag (say youtube) has tag[:require_between] == true and tag[:allow_tag_param].nil?
      # then the :between is assumed to be the param...  that is, a tag that should respond 'true' to tag.requires_param?  
      tag = @bbtree.current_node.definition
      tag[:allow_tag_param_between] and @bbtree.current_node.param_not_set?
    end
    
    
    
    # This function is essentially a duplication of 'expecting_a_closing_tag?'
    # I'm not exactly sure what to do... they use two different methods of lookup...
    # I wonder if the @bbtree_depth variable is entirely redundant...  After checking, it
    # is a possible candidate for becoming a new object class...
    # Responsibilities:  
    #   #escalate_bbtree
    #   #retrogress_bbtree
    #   #use_between_as_tag_param
    #   
    #
    #   #depth
    #   #[](key)  aka @bbtree aka the_hash_data...
    #   #within_open_tag? ..???
    #   #parent_has_constraints_on_children?
    #   #candidate_for_using_between_as_param?
    #
    #  ... the @bbtree should have a container for many TagNodes... Fuck... this is so complicated rightnow...
    #   FIXME:  Consider the merits of the above proposal when you're not so sleepy
    def within_open_tag?
      @bbtree.within_open_tag?
    end
    
    def parent_tag
      @bbtree.parent_tag
    end
    
    def parent_has_constraints_on_children?
      @bbtree.parent_has_constraints_on_children?
    end
    
    
    # Uggghhh...  I tried to make the regex easier to read but it's just not happening...
    # Here are my notes on it...
    # This method doesn't actually do anything.  
    # TODO:  Delete this method before you issue the pull request, I think it's sloppy and unhelpful
    def regex_notes
      # I'm refactoring the regex into modules that explain what it's doing...
      start_of_tag = '\['
      closing_tag_slash = '(\/)?'
      tag_name = '(\w+)'
      param_after_equal_sign = '(=[^\[\]]+)'
      param_after_space = '(\s\w+=\w+)*'    # words then the equal sign in the parameter slot...
      odd1 = '([^\]]*)'    # Captures any number of characters but NOT close bracket...  So parameters?  Or maybe the tag name somehow??...
      odd3 = '([^\[]+)'
      #regex_string = "((#{start_of_tag} #{closing_tag_slash} #{tag_name} (#{param_after_equal_sign} | #{param_after_space} | #{odd1})? \\]) | #{odd3})"
      #regex_string = '((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))'
      regex_string = '(
                        (\[ 
                          (\/)? 
                          (\w+) 
                          (
                            (=[^\[\]]+) | 
                            (\s\w+=\w+)* | 
                            ([^\]]*)
                          )? 
                          \]
                        ) | 
                        (
                          [^\[]+
                        )
                      )'
    end
    
  end
end