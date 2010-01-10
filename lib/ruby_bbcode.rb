require 'tags/tags'

class RubyBBCode
  include BBCode::Tags

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
    text.scan(/\[(\/?)([a-z]*)\]/) do |tag_info|
      ti_openclosed = tag_info[0]
      ti_tag = tag_info[1]
      puts "Found " + tag_info.inspect
      if @@tags.include?(ti_tag.to_sym)
        tag = @@tags[ti_tag.to_sym]
        puts "Found " + tag.inspect
        if ti_openclosed == ''
          tags_list += [ti_tag]
        else
          return ["Closing tag [/#{ti_tag}] does match [#{tags_list.last}]"] if tags_list.last != ti_tag
          tags_list -= [ti_tag]
        end
      end
    end
    return ["[#{tags_list.last}] is not closed"] if tags_list.size != 0

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
end
