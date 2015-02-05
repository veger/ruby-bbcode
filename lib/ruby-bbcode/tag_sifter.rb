require 'active_support/core_ext/array/conversions'

module RubyBBCode
  # TagSifter is in charge of building up the BBTree with nodes as it parses through the
  # supplied text such as
  #    "[b]I'm bold and the next word is [i]ITALIC[/i][b]"
  class TagSifter
    attr_reader :bbtree, :errors

    def initialize(text_to_parse, dictionary, escape_html = true)
      @text = escape_html ? text_to_parse.gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', "&quot;") : text_to_parse

      @dictionary = dictionary # dictionary containing all allowed/defined tags
      @bbtree = BBTree.new({:nodes => TagCollection.new}, dictionary)
      @ti = nil
      @errors = []
    end

    def valid?
      @errors.empty?
    end

    # BBTree#process_text is responsible for parsing the actual BBCode text and converting it
    # into a 'syntax tree' of nodes, each node represeting either a tag type or content for a tag
    # once this tree is built, the to_html method can be invoked where the tree is finally
    # converted into HTML syntax.
    def process_text
      regex_string = '((\[ (\/)? ( \* | (\w+)) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))'
      @text.scan(/#{regex_string}/ix) do |tag_info|
        @ti = TagInfo.new(tag_info, @dictionary)

        # if the tag isn't in the @dictionary list, then treat it as text
        @ti.handle_tag_as_text if @ti.element_is_tag? and !@ti.tag_in_dictionary?
        handle_closing_tags_that_are_multi_as_text_if_it_doesnt_match_the_latest_opener_tag_on_the_stack

        validate_element

        case @ti.type
        when :opening_tag
          element = {:is_tag => true, :tag => @ti[:tag], :definition => @ti.definition, :errors => @ti[:errors], :nodes => TagCollection.new }
          element[:params] = get_formatted_element_params

          @bbtree.retrogress_bbtree if self_closing_tag_reached_a_closer?

          @bbtree.build_up_new_tag(element)

          @bbtree.escalate_bbtree(element)
        when :text
          tag_def = @bbtree.current_node.definition
          if tag_def and tag_def[:multi_tag] == true
            set_parent_tag_from_multi_tag_to_concrete!
            tag_def = @bbtree.current_node.definition
          end

          if within_open_tag? and tag_def[:require_between]
            @bbtree.current_node[:between] = get_formatted_between
            if use_text_as_parameter?
              # Between text should be used as (first) parameter
              @bbtree.current_node[:params][tag_def[:param_tokens][0][:token]] = @bbtree.current_node[:between]
            end
            next  # don't add this node to @bbtree.current_node.children if we're within an open tag that requires_between (to be a param), and the between couldn't be used as a param... Yet it passed validation so the param must have been specified within the opening tag???
          end

          element = {:is_tag => false, :text => @ti.text, :errors => @ti[:errors] }
          @bbtree.build_up_new_tag(element)
        when :closing_tag
          @bbtree.retrogress_bbtree if parent_of_self_closing_tag? and within_open_tag?
          @bbtree.retrogress_bbtree
        end

      end # end of scan loop

      validate_all_tags_closed_off
      validate_stack_level_too_deep_potential
    end

    def set_parent_tag_from_multi_tag_to_concrete!
      # if the proper tag can't be matched, we need to treat the parent tag as text instead!  Or throw an error message....

      tag = get_actual_tag
      if tag == :tag_not_found
        @bbtree.redefine_parent_tag_as_text

        @bbtree.nodes << TagNode.new(@ti.tag_data)      # escalate the bbtree with this element as though it's regular text data...
        return
      end
      @bbtree.current_node[:definition] = @dictionary[tag]
      @bbtree.current_node[:tag] = tag
    end

    # The media tag support multiple other tags, this method checks the tag url param to find actual tag type (to use)
    def get_actual_tag
      supported_tags = @bbtree.current_node[:definition][:supported_tags]

      supported_tags.each do |tag|
        regex_list = @dictionary[tag][:url_matches]

        regex_list.each do |regex|
          return tag if regex =~ @ti.text
        end
      end
      :tag_not_found
    end

    def handle_closing_tags_that_are_multi_as_text_if_it_doesnt_match_the_latest_opener_tag_on_the_stack
      if @ti.element_is_closing_tag?
        return if @bbtree.current_node[:definition].nil?
        if parent_tag != @ti[:tag] and @bbtree.current_node[:definition][:multi_tag]       # if opening tag doesn't match this closing tag... and if the opener was a multi_tag...
          @ti.handle_tag_as_text
        end
      end
    end

    private

    # Gets the params, and format them if needed...
    def get_formatted_element_params
      params = @ti[:params]
      if @ti.definition[:url_matches]
        # perform special formatting for certain tags
        params[:url] = match_url_id(params[:url], @ti.definition[:url_matches])
      end
      return params
    end

    # Get 'between tag' for tag
    def get_formatted_between
      between = @ti[:text]
      # perform special formatting for cenrtain tags
      between = match_url_id(between, @bbtree.current_node.definition[:url_matches]) if @bbtree.current_node.definition[:url_matches]
      return between
    end

    def match_url_id(url, regex_matches)
      regex_matches.each do |regex|
        if url =~ regex
          id = $1
          return id
        end
      end

      return url # if we couldn't find a match, then just return the url, hopefully it's a valid youtube ID...
    end

    # Validates the element
    def validate_element
      return unless valid_text_or_opening_element?
      return unless valid_closing_element?
      return unless valid_param_supplied_as_text?
    end

    def valid_text_or_opening_element?
      if @ti.element_is_text? or @ti.element_is_opening_tag?
        return false unless valid_opening_tag?
        return false unless valid_constraints_on_child?
      end
      true
    end

    def valid_opening_tag?
      if @ti.element_is_opening_tag?
        if @ti.only_allowed_in_parent_tags? and (!within_open_tag? or !@ti.allowed_in? parent_tag) and !self_closing_tag_reached_a_closer?
          # Tag doesn't belong in the last opened tag
          throw_child_requires_specific_parent_error; return false
        end

        if @ti.invalid_quick_param?
          throw_invalid_quick_param_error
          return false
        end
      end
      true
    end

    def self_closing_tag_reached_a_closer?
      @ti.definition[:self_closable] and @bbtree.current_node[:tag] == @ti[:tag]
    end

    def valid_constraints_on_child?
      if within_open_tag? and parent_has_constraints_on_children?
        # Check if the found tag is allowed
        last_tag_def = @dictionary[parent_tag]
        allowed_tags = last_tag_def[:only_allow]
        if (!@ti[:is_tag] and last_tag_def[:require_between] != true and @ti[:text].lstrip != "") or (@ti[:is_tag] and (allowed_tags.include?(@ti[:tag]) == false))  # TODO: refactor this, it's just too long
          # Last opened tag does not allow tag
          throw_parent_prohibits_this_child_error
          return false
        end
      end
      true
    end

    def valid_closing_element?

      if @ti.element_is_closing_tag?
        if parent_tag != @ti[:tag] and !parent_of_self_closing_tag?
          @errors << "Closing tag [/#{@ti[:tag]}] doesn't match [#{parent_tag}]"
          return false
        end

        tag_def = @bbtree.current_node.definition
        if tag_def[:require_between] and @bbtree.current_node[:between].nil?
          add_tag_error "No text between [#{@ti[:tag]}] and [/#{@ti[:tag]}] tags.", @bbtree.current_node
          return false
        end
      end
      true
    end

    def parent_of_self_closing_tag?
      tag_being_parsed = @ti.definition
      was_last_tag_self_closable = @bbtree.current_node[:definition][:self_closable] unless @bbtree.current_node[:definition].nil?

      was_last_tag_self_closable and last_tag_fit_in_this_tag?
    end

    def last_tag_fit_in_this_tag?
      @ti.definition[:only_allow].each do |tag|
        return true if tag == @bbtree.current_node[:tag]
      end unless @ti.definition[:only_allow].nil?
      return false
    end

    # This validation is for text elements with between text
    # that might be construed as a param.
    # The validation code checks if the params match constraints
    # imposed by the node/tag/parent.
    def valid_param_supplied_as_text?
      tag_def = @bbtree.current_node.definition

      # this conditional ensures whether the validation is apropriate to this tag type
      if @ti.element_is_text? and within_open_tag? and tag_def[:require_between] and use_text_as_parameter?

        # check if valid
        if @ti[:text].match(tag_def[:quick_param_format]).nil?
          add_tag_error tag_def[:quick_param_format_description].gsub('%param%', @ti[:text])
          return false
        end
      end
      true
    end

    def validate_all_tags_closed_off
      # if we're still expecting a closing tag and we've come to the end of the string... throw error
      @errors << "[#{@bbtree.tags_list.to_sentence(to_sentence_bbcode_tags)}] not closed" if expecting_a_closing_tag?
    end

    def validate_stack_level_too_deep_potential
      if @bbtree.nodes.count > 2200
        throw_stack_level_will_be_too_deep_error
      end
    end

    def throw_child_requires_specific_parent_error
      err = "[#{@ti[:tag]}] can only be used in [#{@ti.definition[:only_in].to_sentence(to_sentence_bbcode_tags)}]"
      err += ", so using it in a [#{parent_tag}] tag is not allowed" if expecting_a_closing_tag?
      add_tag_error err
    end

    def throw_invalid_quick_param_error
      add_tag_error @ti.definition[:quick_param_format_description].gsub('%param%', @ti[:invalid_quick_param])
    end

    def throw_parent_prohibits_this_child_error
      allowed_tags = @dictionary[parent_tag][:only_allow]
      err = "[#{parent_tag}] can only contain [#{allowed_tags.to_sentence(to_sentence_bbcode_tags)}] tags, so "
      err += "[#{@ti[:tag]}]" if @ti[:is_tag]
      err += "\"#{@ti[:text]}\"" unless @ti[:is_tag]
      err += ' is not allowed'
      add_tag_error err
    end

    def throw_stack_level_will_be_too_deep_error
      @errors << "Stack level would go too deep.  You must be trying to process a text containing thousands of BBTree nodes at once.  (limit around 2300 tags containing 2,300 strings).  Check RubyBBCode::TagCollection#to_html to see why this validation is needed."
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

    def use_text_as_parameter?
      tag_def = @bbtree.current_node.definition
      tag_def[:allow_between_as_param] and @bbtree.current_node.params_not_set?
    end

    def parent_tag
      @bbtree.parent_tag
    end

    def parent_has_constraints_on_children?
      @bbtree.parent_has_constraints_on_children?
    end

    private

    def add_tag_error(message, tag = @ti)
      @errors << message
      tag[:errors] << message
    end

  end
end
