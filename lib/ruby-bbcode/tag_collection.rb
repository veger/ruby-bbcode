module RubyBBCode
  class TagCollection
    def initialize(text, tags)
      @text = text
      @defined_tags = tags
      @tags_list = []
      @bbtree = BBTree.new({:nodes => []})
      @bbtree_depth = 0
      @bbtree_current_node = @bbtree
      
      @last_tag_symbol = ''
      @current_ti = nil
      
      @tag_info_collection = []
      @errors = false
    end
    
    def process_text
      @text.scan(/((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))/ix) do |tag_info|
        
        @current_ti = TagInfo.new(tag_info, @defined_tags)
        ti = @current_ti
        tag = ti.definition
        
        ti.handle_unregistered_tags_as_text  # if the tag isn't in the @defined_tags list, then treat it as text
        
        return if !valid_element?
        
        # Validation of tag succeeded, add to @tags_list and/or bbtree
        if ti.element_is_opening_tag?
          element = {:is_tag => true, :tag => ti[:tag].to_sym, :nodes => [] }
          element[:params] = {:tag_param => ti[:params][:tag_param]} if ti.can_have_params? and ti.has_params?
          @bbtree_current_node[:nodes] << BBTree.new(element) unless element.nil?  # FIXME:  It can't be nil here... but can elsewhere
          escalate_bbtree(element)
        elsif ti.element_is_text?
          element = {:is_tag => false, :text => ti.text }
          if @bbtree_depth > 0  # FIXME:  I think there's a redundancy of methods for looking up if we're "Expecting a closing tag" aka "we're within an open tag"
            tag = @defined_tags[@bbtree_current_node[:tag]]
            if tag[:require_between]
              @bbtree_current_node[:between] = ti[:text]
              if candidate_for_using_between_as_param?
                use_between_as_tag_param    # Did not specify tag_param, so use between.
              end
              element = nil
            end
          end

          @bbtree_current_node[:nodes] << BBTree.new(element) unless element.nil?
          
        elsif ti.element_is_closing_tag?
          retrogress_bbtree
        end
      end
    end
    
    def valid_element?
      return false if !valid_text_or_opening_element?
      return false if !valid_closing_element?
      return false if !valid_param_supplied_as_text?
      true  
    end
    
    def use_between_as_tag_param
      ti = @current_ti
      @bbtree_current_node[:params] = {:tag_param => ti[:text]}
    end
    
    # Advance to next level (the node we just added)
    def escalate_bbtree(element)
      ti = @current_ti
      @tags_list.push ti[:tag]
      @bbtree_current_node = BBTree.new(element)
      @bbtree_depth += 1
    end
    
    # Step down the bbtree a notch because we've reached a closing tag
    def retrogress_bbtree
      @tags_list.pop # remove latest tag in tags_list since it's closed now

      # Find parent node (kinda hard since no link to parent node is available...)
      @bbtree_depth -= 1
      @bbtree_current_node = @bbtree
      @bbtree_depth.times { @bbtree_current_node = @bbtree_current_node[:nodes].last }  # FIXME:  fuck...  I wonder what this shit's about...  I think I need @bbtree[:nodes] to actually be a hash... but contain BBTree elements??...
    end
    
    def valid_text_or_opening_element?
      ti = @current_ti
      
      if ti.element_is_text? or ti.element_is_opening_tag?
        # TODO:  rename this if statement to #validate_opening_tag
        if ti.element_is_opening_tag?
          unless ti.allowed_outside_parent_tags? or (expecting_a_closing_tag? and ti.allowed_in(parent_tag.to_sym))
            # Tag doesn't belong in the last opened tag
            throw_child_requires_specific_parent_error; return false
          end
  
          # Originally:  tag[:allow_tag_param] and ti[:params][:tag_param] != nil
          if ti.can_have_params? and ti.has_params?
            # Test if matches
            if ti.invalid_param?
              throw_invalid_param_error; return false
            end
          end
        end
        
        # TODO:  Rename this if statement to #validate_constraints_on_child
        if expecting_a_closing_tag? and parent_has_constraints_on_children?
          # Check if the found tag is allowed
          last_tag = @defined_tags[parent_tag]
          allowed_tags = last_tag[:only_allow]
          if (!ti[:is_tag] and last_tag[:require_between] != true and ti[:text].lstrip != "") or (ti[:is_tag] and (allowed_tags.include?(ti[:tag].to_sym) == false))  # TODO: refactor this
            # Last opened tag does not allow tag
            throw_parent_prohibits_this_child_error; return false
          end
        end
      end
      true
    end
    
    def valid_closing_element?
      ti = @current_ti
      tag = ti.definition
      
      if ti.element_is_closing_tag?
        if parent_tag != ti[:tag].to_sym
          @errors = ["Closing tag [/#{ti[:tag]}] does match [#{parent_tag}]"] 
          return false
        end
        if tag[:require_between] == true and @bbtree_current_node[:between].blank?
          @errors = ["No text between [#{ti[:tag]}] and [/#{ti[:tag]}] tags."]
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
      ti = @current_ti
      tag = @defined_tags[@bbtree_current_node[:tag]]
      
      # this conditional ensures whether the validation is apropriate to this tag type
      if ti.element_is_text? and @bbtree_depth > 0 and tag[:require_between] and candidate_for_using_between_as_param?
      
        # check if valid
        if ti[:text].match(tag[:tag_param]).nil?
          @errors = [tag[:tag_param_description].gsub('%param%', ti[:text])]
          return false
        end
      end
      true
    end
    
    def candidate_for_using_between_as_param?
      # TODO:  the bool values... 
      # are unclear and should be worked on.  Additional tag might be tag[:requires_param] such that
      # [img] would have that as true...  and [url] would have that as well...  
      # as it is now, if a tag (say youtube) has tag[:require_between] == true and tag[:allow_tag_param].nil?
      # then the :between is assumed to be the param...  that is, a tag that should respond 'true' to tag.requires_param?  
      tag = @defined_tags[@bbtree_current_node[:tag]]
      tag[:allow_tag_param_between] and @bbtree_current_node.param_not_set?
    end
    
    def throw_child_requires_specific_parent_error
      ti = @current_ti
      err = "[#{ti[:tag]}] can only be used in [#{ti.definition[:only_in].to_sentence(RubyBBCode.to_sentence_bbcode_tags)}]"
      err += ", so using it in a [#{parent_tag}] tag is not allowed" if expecting_a_closing_tag?
      @errors = [err]
    end
    
    def throw_invalid_param_error
      ti = @current_ti
      @errors = [ti.definition[:tag_param_description].gsub('%param%', ti[:params][:tag_param])]
    end
    
    def throw_parent_prohibits_this_child_error
      ti = @current_ti
      allowed_tags = @defined_tags[parent_tag][:only_allow]
      err = "[#{parent_tag}] can only contain [#{allowed_tags.to_sentence(RubyBBCode.to_sentence_bbcode_tags)}] tags, so "
      err += "[#{ti[:tag]}]" if ti[:is_tag]
      err += "\"#{ti[:text]}\"" unless ti[:is_tag]
      err += ' is not allowed'
      @errors = [err]
    end
    
    def tags_list
      @tags_list
    end
    
    def parent_tag
      return nil if @tags_list.last.nil?
      @tags_list.last.to_sym
    end
    
    def parent_has_constraints_on_children?
      @defined_tags[parent_tag][:only_allow] != nil
    end
    
    def bbtree
      @bbtree
    end
    
    def errors
      @errors
    end
    
    def invalid?
      @errors != false
    end
    
    def expecting_a_closing_tag?
      @tags_list.length > 0
    end
    
    # This function is essentially a duplication of 'expecting_a_closing_tag?'
    # I'm not exactly sure what to do... they use two different methods of lookup...
    # I wonder if the @bbtree_depth variable is entirely redundant...
    def within_open_tag?
      @bbtree_depth > 0
    end
    
    def tag_valid_for_current_parent?
      tag[:only_in].include?(parent_tag)
    end
    
  end
end