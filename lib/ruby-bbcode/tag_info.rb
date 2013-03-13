module RubyBBCode
  class TagInfo
    def initialize(tag_info, tags)
      @tag_data = find_tag_info(tag_info)
      @tag_dictionary = tags
      @tag_definition = @tag_dictionary[@tag_data[:tag].to_sym] unless @tag_data[:tag].nil?
      
      #unless @tag_data[:tag].nil?
        #binding.pry
      #end
    end
    
    def [](key)
      @tag_data[key]
    end
    
    def []=(key, value)
      @tag_data[key] = value
    end
    
    def handle_unregistered_tags_as_text
      if element_is_tag? and tag_missing_from_tag_list?
        # Handle as text from now on!
        self[:is_tag] = false
        self[:text] = self[:complete_match]
      end
    end
    
    def allowed_outside_parent_tags?
      @tag_definition[:only_in].nil?
    end
    
    def constrained_to_within_parent_tags?
      !@tag_definition[:only_in].nil?
    end
    
    def element_is_tag?
      self[:is_tag]
    end
    
    def element_is_opening_tag?
      self[:is_tag] and !self[:closing_tag]
    end
    
    def element_is_text?
      !self[:text].nil?
    end

    def tag_missing_from_tag_list?
      !@tag_dictionary.include?(self[:tag].to_sym)
    end

    def find_tag_info(tag_info)
      ti = {}
      ti[:complete_match] = tag_info[0]
      ti[:is_tag] = (tag_info[0].start_with? '[')
      if ti[:is_tag]
        ti[:closing_tag] = (tag_info[2] == '/')
        ti[:tag] = tag_info[3]
        ti[:params] = {}
        if tag_info[4][0] == ?=
          ti[:params][:tag_param] = tag_info[4][1..-1]
        elsif tag_info[4][0] == ?\s
          #TODO: Find params
        end
      else
        # Plain text
        ti[:text] = tag_info[8]
      end
      ti
    end
    
    def tag_data
      @tag_data
    end
    
    def definition
      @tag_definition
    end
    
    def allowed_in(tag_symbol)
      @tag_definition[:only_in].include?(tag_symbol)
    end
    
    def can_have_params?
      @tag_definition[:allow_tag_param]
    end
    
    def has_params?
      @tag_data[:params][:tag_param] != nil
    end
    
    def invalid_param?
      @tag_data[:params][:tag_param].match(@tag_definition[:tag_param]).nil?
    end
    
    # This represents the text value of the element (if it's not a tag element)
    # Newlines are converted to html <br /> syntax before being returned.  
    def text
      text = @tag_data[:text]
      # convert_newlines_to_br  
      text.gsub!("\r\n", "\n")
      text.gsub!("\n", "<br />\n")
      text
    end
    
  end
end
