require 'tags/tags'

class RubyBBCode
  include BBCode::Tags

  def self.to_html(text, escape_html = true, additional_tags = {}, method = :disable, *tags)
    text
  end

  def self.is_valid?(text)
    false
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
