module RubyBBCode
  # TagInfo is basically what the regex scan get's converted into
  # during the tag_sifter#process_text method.
  # This class was made mostly just to keep track of all of the confusing
  # the logic conditions that are checked.
  #
  class TagInfo
    def initialize(tag_info, dictionary)
      @tag_data = find_tag_info(tag_info)
      @dictionary = dictionary
      @definition = @dictionary[@tag_data[:tag]] unless @tag_data[:tag].nil?
    end

    def [](key)
      @tag_data[key]
    end

    def []=(key, value)
      @tag_data[key] = value
    end

    def tag_data
      @tag_data
    end

    def definition
      @definition
    end

    def definition=(val)
      @definition = val
    end

    def dictionary   # need this for reasigning multi_tag elements
      @dictionary
    end

    # This represents the text value of the element (if it's not a tag element)
    def text
      @tag_data[:text]
    end

    # allows for a very snazy case/ when conditional
    def type
      return :opening_tag if element_is_opening_tag?
      return :text if element_is_text?
      return :closing_tag if element_is_closing_tag?
    end

    def handle_tag_as_text
      self[:is_tag] = false
      self[:closing_tag] = false
      self[:text] = self[:complete_match]
    end

    def element_is_tag?
      self[:is_tag]
    end

    def element_is_opening_tag?
      self[:is_tag] and !self[:closing_tag]
    end

    def element_is_closing_tag?
      self[:is_tag] and  self[:closing_tag]
    end

    def element_is_text?
      !self[:is_tag]
    end

    def tag_in_dictionary?
      @dictionary.include?(self[:tag])
    end

    def only_allowed_in_parent_tags?
      !@definition[:only_in].nil?
    end

    def allowed_in(tag_symbol)
      return true unless only_allowed_in_parent_tags?
      @definition[:only_in].include?(tag_symbol)
    end

    def can_have_quick_param?
      @definition[:allow_quick_param]
    end

    def has_quick_param?
      self[:params][:quick_param] != nil
    end

    # Checks if the tag param matches the regex pattern defined in tags.rb
    def invalid_quick_param?
      self[:params][:quick_param].match(@definition[:quick_param_format]).nil?
    end

    protected

    def find_tag_info(tag_info)
      ti = {}
      ti[:complete_match] = tag_info[0]
      ti[:is_tag] = (tag_info[0].start_with? '[')
      if ti[:is_tag]
        ti[:closing_tag] = (tag_info[2] == '/')
        ti[:tag] = tag_info[3].to_sym
        ti[:params] = {}
        if tag_info[5][0] == ?=
          ti[:params][:quick_param] = tag_info[5][1..-1]
        elsif tag_info[5][0] == ?\s
          regex_string = '((\w+)=(\w+)) | ((\w+)="([^"]+)") | ((\w+)=\'([^\']+)\')'
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
