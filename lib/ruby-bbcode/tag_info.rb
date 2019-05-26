module RubyBBCode
  # TagInfo is basically what the regex scan get's converted into during the TagSifter#process_text method.
  # This class was made mostly just to keep track of all of the confusing the logic conditions that are checked.
  #
  class TagInfo
    def initialize(tag_info, dictionary)
      @tag_data = find_tag_info(tag_info, dictionary)
    end

    def [](key)
      @tag_data[key]
    end

    def []=(key, value)
      @tag_data[key] = value
    end

    # Definition of this instance (when it represents a tag element)
    attr_reader :definition

    # Returns the text (when this instance represents a text element)
    def text
      @tag_data[:text]
    end

    # Returns the type of the cuvvrent tag/node, which is either :opening_tag, :closing_tag, or :text
    def type
      return :opening_tag if element_is_opening_tag?
      return :text if element_is_text?
      return :closing_tag if element_is_closing_tag?
    end

    # Converts this instance (from a tag) into a text element
    def handle_tag_as_text
      self[:is_tag] = false
      self[:closing_tag] = false
      self[:text] = self[:complete_match]
    end

    # Returns true if this instance represents a tag element
    def element_is_tag?
      self[:is_tag]
    end

    # Returns true if this instance represents a text element
    def element_is_text?
      !self[:is_tag]
    end

    # Returns true if this instance represents an opening tag element
    def element_is_opening_tag?
      self[:is_tag] && !self[:closing_tag]
    end

    # Returns true if this instance represents a closing tag element
    def element_is_closing_tag?
      self[:is_tag] &&  self[:closing_tag]
    end

    # Returns true if this tag element is included in the set of available tags
    def tag_in_dictionary?
      !@definition.nil?
    end

    # Returns true if the tag that is represented by this instance is restricted on where it is allowed, i.e. if it is restricted by certain parent tags.
    def only_allowed_in_parent_tags?
      !@definition[:only_in].nil?
    end

    # Returns true if the tag element is allowed in the provided parent_tag
    def allowed_in?(parent_tag)
      !only_allowed_in_parent_tags? || @definition[:only_in].include?(parent_tag)
    end

    # Returns true if this tag has quick parameter support
    def can_have_quick_param?
      @definition[:allow_quick_param]
    end

    # Returns true if the tag param matches the regex pattern defined in tags.rb
    def invalid_quick_param?
      @tag_data.key? :invalid_quick_param
    end

    protected

    # Returns a default info structure used by all tags
    def default_tag_info(tag_info)
      {
        errors: [],
        complete_match: tag_info[0]
      }
    end

    # Convert the result of the TagSifter#process_text regex into a more usable hash, that is used by the rest of the parser.
    # tag_info should a result of the regex of TagSifter#process_text
    # Returns the tag hash
    def find_tag_info(tag_info, dictionary)
      ti = default_tag_info(tag_info)
      ti[:is_tag] = (tag_info[0].start_with? '[')
      if ti[:is_tag]
        ti[:closing_tag] = (tag_info[2] == '/')
        ti[:tag] = tag_info[3].to_sym.downcase
        ti[:params] = {}
        @definition = dictionary[ti[:tag]]
        if !tag_in_dictionary?
          # Tag is not defined in dictionary, so treat as text
          raise "unknown tag #{ti[:tag]}" unless RubyBBCode.configuration.ignore_unknown_tags

          ti = default_tag_info(tag_info)
          ti[:is_tag] = false
          ti[:text] = tag_info[0]
        elsif (tag_info[5][0] == '=') && can_have_quick_param?
          quick_param = tag_info[5][1..-1]
          # Get list of parameter values and add them as (regular) parameters
          value_array = quick_param.scan(@definition[:quick_param_format])[0]
          if value_array.nil?
            ti[:invalid_quick_param] = quick_param
          else
            param_tokens = @definition[:param_tokens]
            value_array[0..param_tokens.length - 1].each.with_index do |value, i|
              ti[:params][param_tokens[i][:token]] = value
            end
          end
        elsif tag_info[5][0] == "\s"
          regex_string = '((\w+)=([\w#]+)) | ((\w+)="([^"]+)") | ((\w+)=\'([^\']+)\')'
          tag_info[5].scan(/#{regex_string}/ix) do |param_info|
            param = param_info[1] || param_info[4] || param_info[7]
            value = param_info[2] || param_info[5] || param_info[8]
            ti[:params][param.to_sym] = value
          end
        end
      else
        # Plain text
        ti[:text] = tag_info[9]
      end
      ti
    end
  end
end
