module RubyBBCode
  class TagCollection
    def initialize(text, tags)
      @text = text
      @defined_tags = tags
      @tags_list = []
      @bbtree = {:nodes => []}
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
        
        # if it's text or if it's an opening tag...
        # originally:  !ti[:is_tag] or !ti[:closing_tag]
        if ti.element_is_text? or ti.element_is_opening_tag?
          return if !valid_text_or_opening_element?

          # Validation of tag succeeded, add to @tags_list and/or bbtree
          if ti.element_is_tag?
            @tags_list.push ti[:tag]
            element = {:is_tag => true, :tag => ti[:tag].to_sym, :nodes => [] }
            element[:params] = {:tag_param => ti[:params][:tag_param]} if ti.can_have_params? and ti.has_params?
          elsif ti.element_is_text?
            
            element = {:is_tag => false, :text => ti.text }
            if @bbtree_depth > 0
              tag = @defined_tags[@bbtree_current_node[:tag]]
              #binding.pry
              if tag[:require_between] == true
                @bbtree_current_node[:between] = ti[:text]
                if tag[:allow_tag_param] and tag[:allow_tag_param_between] and 
                     (@bbtree_current_node[:params] == nil or @bbtree_current_node[:params][:tag_param] == nil)
                  # Did not specify tag_param, so use between.
                  
                  return if !valid_param_supplied_as_text?
                  
                  # Store as tag_param
                  @bbtree_current_node[:params] = {:tag_param => ti[:text]}
                end
                element = nil
              end
            end
          end
          #binding.pry
          
          
          @bbtree_current_node[:nodes] << element unless element == nil
          
          if ti[:is_tag]
            # Advance to next level (the node we just added)
            @bbtree_current_node = element
            @bbtree_depth += 1
          end
        end
        
  
        if ti[:is_tag] and ti[:closing_tag]
          return if !valid_closing_element?
          
          @tags_list.pop # remove latest tag in tags_list since it's closed now

          # Find parent node (kinda hard since no link to parent node is available...)
          @bbtree_depth -= 1
          @bbtree_current_node = @bbtree
          @bbtree_depth.times { @bbtree_current_node = @bbtree_current_node[:nodes].last }
        end
        
        #RubyBBCode.log(@bbtree_depth.inspect)
      end
    end
    
    def valid_text_or_opening_element?
      ti = @current_ti
      
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
      
      true
    end
    
    def valid_closing_element?
      ti = @current_ti
      tag = ti.definition
      
      if parent_tag != ti[:tag].to_sym
        @errors = ["Closing tag [/#{ti[:tag]}] does match [#{parent_tag}]"] 
        return false
      end
      if tag[:require_between] == true and @bbtree_current_node[:between].blank?
        @errors = ["No text between [#{ti[:tag]}] and [/#{ti[:tag]}] tags."]
        return false
      end
      
      true
    end
    
    def valid_param_supplied_as_text?
      ti = @current_ti
      tag = @defined_tags[@bbtree_current_node[:tag]]
      
      # Check if valid
      if ti[:text].match(tag[:tag_param]).nil?
        @errors = [tag[:tag_param_description].gsub('%param%', ti[:text])]
        return false
      end
      true
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
    
    def tag_valid_for_current_parent?
      tag[:only_in].include?(parent_tag)
    end
    
  end
end