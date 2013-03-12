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
      
      @tag_info_collection = []
      @errors = false
      
      commence_scan
    end
    
    def commence_scan
      @text.scan(/((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))/ix) do |tag_info|
        
        ti = TagInfo.new(tag_info, @defined_tags)    # TODO:  ti should be a full fledged class, not just a hash... it should have methods like #handle_bracketed_item_as_text...
  
        ti.handle_unregistered_tags_as_text  # if the tag isn't in the @defined_tags list, then treat it as text
        
        # if it's text or if it's an opening tag...
        # originally:  !ti[:is_tag] or !ti[:closing_tag]
        if ti.element_is_text? or ti.element_is_opening_tag?
          
          left = !ti[:is_tag] and !ti.element_is_opening_tag?
          right = ti[:is_tag] and ti.element_is_opening_tag?
          # debugging
          if right
            #log("got here...")
            #log(ti[:closing_tag].inspect)
            #log(ti.tag_data.inspect)
          end
          
          # if it's an opening tag...
          # originally:  ti[:is_tag]
          if ti.element_is_opening_tag?
            tag = @defined_tags[ti[:tag].to_sym]
            
            # ti.allowed_in(@tags_list.last.to_sym)
            unless ti.allowed_outside_parent_tags? or (expecting_a_closing_tag? and ti.allowed_in(parent_tag.to_sym))
              #binding.pry
              # Tag does to be put in the last opened tag
              err = "[#{ti[:tag]}] can only be used in [#{tag[:only_in].to_sentence(RubyBBCode.to_sentence_bbcode_tags)}]"
              err += ", so using it in a [#{parent_tag}] tag is not allowed" if @tags_list.length > 0
              @errors = [err]  # TODO: Currently working on this...
              #return [err]
              return   # TODO:  refactor these returns so that they follow a case when style syntax...  I think this will break things
                       #  Like when you parse a huge string, and it contains 1 error at the top... it will stop scanning the file
                       #  when a return is struck because it's popping completely out of the class and won't have a chance to keep scanning
                       #  ... although wait a second... that's the current behavior isn't it??
            end
  
            if tag[:allow_tag_param] and ti[:params][:tag_param] != nil
              # Test if matches
              if ti[:params][:tag_param].match(tag[:tag_param]).nil?
                @errors = [tag[:tag_param_description].gsub('%param%', ti[:params][:tag_param])]
                return
              end
            end
          end
  
          if @tags_list.length > 0 and  @defined_tags[parent_tag][:only_allow] != nil
            # Check if the found tag is allowed
            last_tag = @defined_tags[parent_tag]
            allowed_tags = last_tag[:only_allow]
            if (!ti[:is_tag] and last_tag[:require_between] != true and ti[:text].lstrip != "") or (ti[:is_tag] and (allowed_tags.include?(ti[:tag].to_sym) == false))
              # Last opened tag does not allow tag
              err = "[#{parent_tag}] can only contain [#{allowed_tags.to_sentence(RubyBBCode.to_sentence_bbcode_tags)}] tags, so "
              err += "[#{ti[:tag]}]" if ti[:is_tag]
              err += "\"#{ti[:text]}\"" unless ti[:is_tag]
              err += ' is not allowed'
              @errors = [err]
              return
            end
          end
  
          # Validation of tag succeeded, add to @tags_list and/or bbtree
          if ti[:is_tag]
            tag = @defined_tags[ti[:tag].to_sym]
            @tags_list.push ti[:tag]
            element = {:is_tag => true, :tag => ti[:tag].to_sym, :nodes => [] }
            element[:params] = {:tag_param => ti[:params][:tag_param]} if tag[:allow_tag_param] and ti[:params][:tag_param] != nil
          else
            text = ti[:text]
            text.gsub!("\r\n", "\n")
            text.gsub!("\n", "<br />\n")
            element = {:is_tag => false, :text => text }
            if @bbtree_depth > 0
              tag = @defined_tags[@bbtree_current_node[:tag]]
              if tag[:require_between] == true
                @bbtree_current_node[:between] = ti[:text]
                if tag[:allow_tag_param] and 
                     tag[:allow_tag_param_between] and 
                     (@bbtree_current_node[:params] == nil or 
                     @bbtree_current_node[:params][:tag_param] == nil)
                  # Did not specify tag_param, so use between.
                  
                  # Check if valid
                  if ti[:text].match(tag[:tag_param]).nil?
                    @errors = [tag[:tag_param_description].gsub('%param%', ti[:text])]
                    return
                  end
                  
                  # Store as tag_param
                  @bbtree_current_node[:params] = {:tag_param => ti[:text]} 
                end
                element = nil
              end
            end
          end
          @bbtree_current_node[:nodes] << element unless element == nil
          if ti[:is_tag]
            # Advance to next level (the node we just added)
            @bbtree_current_node = element
            @bbtree_depth += 1
          end
        end
        
  
        if  ti[:is_tag] and ti[:closing_tag]
          if ti[:is_tag]
            tag = @defined_tags[ti[:tag].to_sym]
            
            #binding.pry
            if parent_tag != ti[:tag].to_sym
              @errors = ["Closing tag [/#{ti[:tag]}] does match [#{parent_tag}]"] 
              return
            end
            if tag[:require_between] == true and @bbtree_current_node[:between].blank?
              @errors = ["No text between [#{ti[:tag]}] and [/#{ti[:tag]}] tags."]
              return
            end
            @tags_list.pop
  
            # Find parent node (kinda hard since no link to parent node is available...)
            @bbtree_depth -= 1
            @bbtree_current_node = @bbtree
            @bbtree_depth.times { @bbtree_current_node = @bbtree_current_node[:nodes].last }
          end
        end
      end
    end
    
    def tags_list
      @tags_list
    end
    
    def parent_tag
      return nil if @tags_list.last.nil?
      @tags_list.last.to_sym
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