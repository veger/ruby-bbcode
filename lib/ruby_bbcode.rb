require 'tags/tags'

class RubyBBCode
  include BBCode::Tags

  @@to_sentence_bbcode_tags = {:words_connector => "], [", 
    :two_words_connector => "] and [", 
    :last_word_connector => "] and ["}

  def self.to_html(text, escape_html = true, additional_tags = {}, method = :disable, *tags)
    # We cannot convert to HTML if the BBCode is not valid!
    text = text.clone

    if escape_html
      text.gsub!('<', '&lt;')
      text.gsub!('>', '&gt;')
    end
    text.gsub!("\r\n", "\n")
    text.gsub!("\n", "<br />\n")

    valid = is_valid?(text)
    raise valid.join(', ') if valid != true

    bbtree_to_html(@bbtree[:nodes])
  end

  def self.is_valid?(text)
    return parse(text);
  end

  def self.tag_list
    @@tags
  end

  protected
  def self.parse(text)
    tags_list = []
    @bbtree = {:nodes => []}
    bbtree_depth = 0
    bbtree_current_node = @bbtree
    between_text = nil
    text.scan(/((\[ (\/)? (\w+) ((=[^\[\]]+) | (\s\w+=\w+)* | ([^\]]*))? \]) | ([^\[]+))/ix) do |tag_info|
      ti = find_tag_info(tag_info)

      if ti[:is_tag] and !@@tags.include?(ti[:tag].to_sym)
        # Handle as text from now on!
        ti[:is_tag] = false
        ti[:text] = ti[:complete_match]
      end
     
      if !ti[:is_tag] or !ti[:closing_tag]
        if ti[:is_tag]
          tag = @@tags[ti[:tag].to_sym]
          unless tag[:only_in].nil? or (tags_list.length > 0 and tag[:only_in].include?(tags_list.last.to_sym))
            # Tag does to be put in the last opened tag
            err = "[#{ti[:tag]}] can only be used in [#{tag[:only_in].to_sentence(@@to_sentence_bbcode_tags)}]"
            err += ", so using it in a [#{tags_list.last}] tag is not allowed" if tags_list.length > 0
            return [err]
          end
        end

        if tags_list.length > 0 and  @@tags[tags_list.last.to_sym][:only_allow] != nil
          # Check if the found tag is allowed
          last_tag = @@tags[tags_list.last.to_sym]
          allowed_tags =  last_tag[:only_allow]
          if (!ti[:is_tag] and last_tag[:require_between] != true) or (ti[:is_tag] and (allowed_tags.include?(ti[:tag].to_sym) == false))
            # Last opened tag does not allow tag
            err = "[#{tags_list.last}] can only contain [#{allowed_tags.to_sentence(@@to_sentence_bbcode_tags)}] tags, so "
            err += "[#{ti[:tag]}]" if ti[:is_tag]
            err += "\"#{ti[:text]}\"" unless ti[:is_tag]
            err += ' is not allowed'
            return [err]
          end
        end
        if ti[:is_tag]
          tags_list += [ti[:tag]]
          element = {:is_tag => true, :tag => ti[:tag].to_sym, :nodes => [] }
        else
          element = {:is_tag => false, :text => ti[:text] }
          if bbtree_current_node[:is_tag]
            tag = @@tags[bbtree_current_node[:tag]]
            if tag[:require_between] == true
              bbtree_current_node[:between] = ti[:text]
              element = nil
            end
          end
        end
        bbtree_current_node[:nodes] << element unless element == nil
        if ti[:is_tag]
          # Advance to next level (the node we just added)
          bbtree_current_node = element
          bbtree_depth += 1
        end
      end

      if  ti[:is_tag] and ti[:closing_tag]
        if ti[:is_tag]
          tag = @@tags[ti[:tag].to_sym]
          return ["Closing tag [/#{ti[:tag]}] does match [#{tags_list.last}]"] if tags_list.last != ti[:tag]
          return ["No text between [#{ti[:tag]}] and [/#{ti[:tag]}] tags."] if tag[:require_between] == true and between_text.blank?
          tags_list -= [ti[:tag]]

          # Find parent node (kinda hard since no link to parent node is available...)
          bbtree_depth -= 1
          bbtree_current_node = @bbtree
          bbtree_depth.times { bbtree_current_node = bbtree_current_node[:nodes].last }
        end
      end

      between_text = (ti[:is_tag] ? nil : ti[:text])

    end
    return ["[#{tags_list.to_sentence((@@to_sentence_bbcode_tags))}] not closed"] if tags_list.length > 0

    puts "tree = " + @bbtree.inspect
    true
  end

  def self.find_tag_info(tag_info)
    ti = {}
    ti[:complete_match] = tag_info[0]
    ti[:is_tag] = tag_info[0].starts_with? '['
    if ti[:is_tag]
      ti[:closing_tag] = (tag_info[2] == '/')
      ti[:tag] = tag_info[3]
      ti[:params] = {}
      if tag_info[4][1] == '='
        ti[:params][:tag_param] = tag_info[4][2..-1]
      elsif tag_info[4][1] == ' '
        #TODO: Find multiple params
      end
    else
      # Plain text
      ti[:text] = tag_info[8]
    end
    ti
  end

  def self.bbtree_to_html(node_list)
    text = ""
    node_list.each do |node|
      if node[:is_tag]
        tag = @@tags[node[:tag]]
        t = tag[:html_open]
        t.gsub!('%between%', node[:between]) if tag[:require_between]
        text += t
        text += bbtree_to_html(node[:nodes]) if node[:nodes].length > 0
        t = tag[:html_close]
        t.gsub!('%between%', node[:between]) if tag[:require_between]
        text += t
      else
        text += node[:text]
      end
    end
    text
  end
end

class String
  # Convert a string with BBCode markup into its corresponding HTML markup
  def bbcode_to_html(escape_html = true, additional_tags = {}, method = :disable, *tags)
    RubyBBCode.to_html(self, escape_html, additional_tags, method, *tags)
  end
  
  # Replace the BBCode content of a string with its corresponding HTML markup
  def bbcode_to_html!(escape_html = true, additional_tags = {}, method = :disable, *tags)
    self.replace(RubyBBCode.to_html(self, escape_html, additional_tags, method, *tags))
  end

  # Check if string contains valid BBCode. Returns true when valid, else returns array with error(s)
  def is_valid_bbcode?
    RubyBBCode.is_valid?(self)
  end
end
