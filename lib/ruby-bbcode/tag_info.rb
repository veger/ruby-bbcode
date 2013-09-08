module RubyBBCode
  # tag info is basically what the regex scan get's converted into 
  # during the tag_sifter#process_text method.
  # This class was made mostly just to keep track of all of the confusing
  # the logic conditions that are checked.  
  #
  class TagInfo
    def initialize(tag_info, dictionary)
      @tag_data = find_tag_info(tag_info)
      @dictionary = dictionary
      @definition = @dictionary[@tag_data[:tag].to_sym] unless @tag_data[:tag].nil?
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
    # Newlines are converted to html <br /> syntax before being returned.  
    def text
      text = @tag_data[:text]
      # convert_newlines_to_br  
      text.gsub!("\r\n", "\n")
      text.gsub!("\n", "<br />\n")
      text
    end
    
    # allows for a very snazy case/ when conditional
    def type
      return :opening_tag if element_is_opening_tag?
      return :text if element_is_text?
      return :closing_tag if element_is_closing_tag?
    end
    
    def handle_unregistered_tags_as_text
      if element_is_tag? and tag_missing_from_tag_dictionary?
        # Handle as text from now on!
        self[:is_tag] = false
        self[:closing_tag] = false
        self[:text] = self[:complete_match]
      end
    end
    
    def element_is_tag?
      self[:is_tag]
    end
    
    def element_is_opening_tag?
      self[:is_tag] and !self[:closing_tag]
    end
    
    def element_is_closing_tag?
      self[:closing_tag]
    end
    
    def element_is_text?
      !self[:text].nil?
    end
    
    def has_params?
      self[:params][:tag_param] != nil
    end
    
    def tag_missing_from_tag_dictionary?
      !@dictionary.include?(self[:tag].to_sym)
    end
    
    def allowed_outside_parent_tags?
      @definition[:only_in].nil?
    end
    
    def constrained_to_within_parent_tags?
      !@definition[:only_in].nil?
    end
    
    def allowed_in(tag_symbol)
      @definition[:only_in].include?(tag_symbol)
    end
    
    def can_have_params?
      @definition[:allow_tag_param]
    end

    # Checks if the tag param matches the regex pattern defined in tags.rb
    def invalid_param?
      self[:params][:tag_param].match(@definition[:tag_param]).nil?
    end
    
    protected
    
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
          #FIXME: Find params... Delete this or write a test to cover this and implement it
        end
      else
        # Plain text
        ti[:text] = tag_info[8]
      end
      ti
    end
    
  end
end
