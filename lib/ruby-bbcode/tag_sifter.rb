require 'pry'
module RubyBBCode
  # Tag sifter is in charge of building up the BBTree with nodes as it parses through the
  # supplied text such as "[b]hello world[/b]"
  class TagSifter
    attr_reader :bbtree, :errors
    
    def initialize(text_to_parse, dictionary, escape_html = true)
      @text = escape_html ? text_to_parse.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', "&quot;") : text_to_parse
      
      @dictionary = dictionary # the dictionary for all the defined tags in tags.rb
      @bbtree = BBTree.new({:nodes => TagCollection.new}, dictionary)
      @ti = nil
      @errors = false
    end
    
    def invalid?
      @errors != false
    end
    
    
    def process_text
      regex_string = '((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))'
      @text.scan(/#{regex_string}/ix) do |tag_info|
        @ti = TagInfo.new(tag_info, @dictionary)
        
        @ti.handle_unregistered_tags_as_text  # if the tag isn't in the @dictionary list, then treat it as text
        
        return if !valid_element?
        
        case @ti.type   # Validation of tag succeeded, add to @bbtree.tags_list and/or bbtree
        when :opening_tag
          #@ti = match_multi_tag(@ti) if @ti.definition[:multi_tag] == true
          element = {:is_tag => true, :tag => @ti[:tag].to_sym, :definition => @ti.definition, :nodes => TagCollection.new }
          #element = handle_multitag(element) if element[:definition][:multi_tag] == true
          element[:params] = {:tag_param => get_formatted_element_params} if @ti.can_have_params? and @ti.has_params?
          @bbtree.build_up_new_tag(element)
          
          @bbtree.escalate_bbtree(element)
        when :text
          set_parent_tag_from_multi_tag_to_concrete! if @bbtree.current_node.definition && @bbtree.current_node.definition[:multi_tag] == true
            
          element = {:is_tag => false, :text => @ti.text }
          if within_open_tag?
            tag = @bbtree.current_node.definition
            #binding.pry
            if tag[:require_between]
              @bbtree.current_node[:between] = get_formatted_element_params
              if candidate_for_using_between_as_param?
                use_between_as_tag_param    # Did not specify tag_param, so use between text.
              end
              next  # don't add this node to @bbtree.current_node.children if we're within an open tag that requires_between (to be a param), and the between couldn't be used as a param... Yet it passed validation so the param must have been specified within the opening tag???
            end
          end
          
          @bbtree.build_up_new_tag(element)
        when :closing_tag
          @bbtree.retrogress_bbtree
        end
        
      end # end of scan loop
      
      
      validate_all_tags_closed_off
      validate_stack_level_too_deep_potential
    end
    
    def set_parent_tag_from_multi_tag_to_concrete!
      proper_tag = get_proper_tag
      @bbtree.current_node[:definition] = @dictionary[proper_tag]
      @bbtree.current_node[:tag] = proper_tag
    end
    
    def get_proper_tag
      ti = @bbtree.current_node[:definition][:supported_tags]
      
      regex_list = @bbtree.current_node[:definition][:supported_tags].each_value.to_a[0]    # FIXME:  this is a hardcoding hack...  needs logic...
      regex_list.each do |regex|
      
        @dictionary.each do |key, val|   # I need to add some fields to the youtube tag to get this to work...
          val[:domains] && val[:domains].each do |domain|
            binding.pry
            if regex =~ domain
              return key
            end
          end
        end
      end
      
    end
    
    
    private
    
    # This method allows us to format params if needed...  
    # TODO:  Maybe this kind of thing *could* be handled in the bbtree_to_html where the %between% is
    # sorted out and the html is generated, but...  That code has yet to be refactored and we can.
    # refactor this code easily to happen over there if necessary...  Yes, I think it's more logical 
    # to be put over there, but that method needs to be cleaned up before we introduce the formatting overthere... and knowing the parent node is helpful!    
    def get_formatted_element_params
      
      if @ti[:is_tag]
        param = @ti[:params][:tag_param]
        if @ti.can_have_params? and @ti.has_params?
          # perform special formatting for cenrtain tags
          binding.pry if @ti[:tag].to_sym == :youtube
          param = parse_youtube_id(param) if @ti[:tag].to_sym == :youtube  # note:  this line isn't ever used because @@tags don't allow it... I think if we have tags without the same kind of :require_between restriction, we'll need to pay close attention to this case
          
        end
        return param
      else  # must be text... @ti[:is_tag] == false
        param = @ti[:text]
        # perform special formatting for cenrtain tags
        #param = parse_youtube_id(param) if @bbtree.current_node[:tag] == :youtube  # this is the old primitive way of doing multi_url format matching
        param = conduct_special_formatting(param) if @bbtree.current_node.definition[:url_matches]
        
        return param
      end
    end
    
    # Parses a youtube video url and extracts the ID  
    def parse_youtube_id(url)
      url =~ /youtube.com.*[v]=([^&]*)/ # /[v]=([^&]*)/
      id = $1
      binding.pry
      
      if id.nil? and url =~ /youtu.be\/([^&]*)/   # if they used youtube's url shortener  youtube.be/ID...  
        return $1
      elsif id.nil?
        # when there is no match for v=blah, then maybe they just 
        # provided us with the ID the way the system used to work... 
        # just "E4Fbk52Mk1w"
        return url  
      else
        # else we got a match for an id and we can return that ID...
        return id
      end
    end
    
    def conduct_special_formatting(url, regex_matches = nil)
      if regex_matches.nil?
        regex_matches = @bbtree.current_node.definition[:url_matches]
      else # we are testing...
        #@bbtree.current_node
      end
      
      #binding.pry
      regex_matches.each do |regex|
        if url =~ regex
          id = $1
          return id
        end
      end
      return url
    end
    
    
    # Validates the element
    def valid_element?
      return false if !valid_text_or_opening_element?
      return false if !valid_closing_element?
      return false if !valid_param_supplied_as_text?
      true
    end
    
    def valid_text_or_opening_element?
      if @ti.element_is_text? or @ti.element_is_opening_tag?
        return false if validate_opening_tag == false
        return false if validate_constraints_on_child == false
      end
      true
    end
    
    def validate_opening_tag
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
      true
    end
    
    def validate_constraints_on_child
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
    
    def validate_stack_level_too_deep_potential
      if @bbtree.nodes.count > 2200
        throw_stack_level_will_be_too_deep_error
      end
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
    
    def throw_stack_level_will_be_too_deep_error
      @errors = ["Stack level would go too deep.  You must be trying to process a text containing thousands of BBTree nodes at once.  (limit around 2300 tags containing 2,300 strings).  Check RubyBBCode::TagCollection#to_html to see why this validation is needed."]
    end
    
    
    def to_sentence_bbcode_tags
      {:words_connector => "], [", 
        :two_words_connector => "] and [", 
        :last_word_connector => "] and ["}
    end
    
    
    def expecting_a_closing_tag?
      @bbtree.expecting_a_closing_tag?
    end
    
    def within_open_tag?
      @bbtree.within_open_tag?
    end
    
    def use_between_as_tag_param
      param = get_formatted_element_params
      @bbtree.current_node.tag_param = param      # @bbtree.current_node[:params] = {:tag_param => @ti[:text]}
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
    
    def parent_tag
      @bbtree.parent_tag
    end
    
    def parent_has_constraints_on_children?
      @bbtree.parent_has_constraints_on_children?
    end
    
  end
end
