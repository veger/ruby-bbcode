require 'tags/tags'

class RubyBBCode
  include BBCode::Tags

  @@to_sentence_bbcode_tags = {:words_connector => "], [", 
    :two_words_connector => "] and [", 
    :last_word_connector => "] and ["}

  def self.to_html(text, escape_html = true, additional_tags = {}, method = :disable, *tags)
    # We cannot convert to HTML if the BBCode is not valid!
    valid = is_valid?(text)
    raise valid.join(', ') if valid != true

    text = text.clone

    if escape_html
      text.gsub!('<', '&lt;')
      text.gsub!('>', '&gt;')
    end
    text.gsub!("\r\n", "\n")
    text.gsub!("\n", "<br />\n")

    @@tags.each do |tag|
      text.gsub!("[#{tag[0].to_s}]", tag[1][:html_open])
      text.gsub!("[/#{tag[0].to_s}]", tag[1][:html_close])
    end

    text
  end

  def self.is_valid?(text)
    tags_list = []
    text.scan(/(\[)(\/?)([a-z][^\]]*)\]|([^\[]+)/i) do |tag_info|
      puts tag_info.inspect + " tl=" + tags_list.inspect
      if tag_info[0] == '['
        ti_istag = true
        ti_openclosed = tag_info[1]
        ti_tag = tag_info[2]
      else
        ti_istag = false
        ti_text = tag_info[3]
      end

      if !ti_istag or @@tags.include?(ti_tag.to_sym)
        if !ti_istag or ti_openclosed == ''
          if ti_istag
            tag = @@tags[ti_tag.to_sym]
            unless tag[:only_in].nil? or (tags_list.length > 0 and tag[:only_in].include?(tags_list.last.to_sym))
              # Tag not allowed in open tag
              err = "[#{ti_tag}] can only be used in [#{tag[:only_in].to_sentence(@@to_sentence_bbcode_tags)}]"
              err += ", so using it in a [#{tags_list.last}] tag is not allowed" if tags_list.length > 0
              return [err]
            end
          end

          puts 'Before allowed ' + ti_tag.to_s + " " + ti_text.to_s if tags_list.last == 'ul'
          if tags_list.length > 0 and  @@tags[tags_list.last.to_sym][:only_allow] != nil
            # Check if the found tag is allowed
            allowed_tags =  @@tags[tags_list.last.to_sym][:only_allow]
            puts "Allowed: " + allowed_tags.inspect + ", current: #{ti_tag}"
            unless ti_istag and allowed_tags.include?(ti_tag.to_sym)
              # Tag not allowed in open tag
              err = "[#{tags_list.last}] can only contain [#{allowed_tags.to_sentence(@@to_sentence_bbcode_tags)}] tags, so "
              err += "[#{ti_tag}]" if ti_istag
              err += "\"#{ti_text}\"" unless ti_istag
              err += ' is not allowed'
              puts err
              return [err]
            end
          end
          tags_list += [ti_tag] if ti_istag
        end

        if ti_openclosed == '/' or !ti_istag
          if ti_istag
            return ["Closing tag [/#{ti_tag}] does match [#{tags_list.last}]"] if tags_list.last != ti_tag
            tags_list -= [ti_tag]
          end
        end
      end
    end
    return ["[#{tags_list.last}] is not closed"] if tags_list.length > 0

    true
  end

  def self.tag_list
    @@tags
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
