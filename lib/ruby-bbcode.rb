require 'active_support/core_ext/array/conversions'

require 'tags/tags'
require 'ruby-bbcode/debugging'
require 'ruby-bbcode/tag_info'
require 'ruby-bbcode/tag_sifter'
require 'ruby-bbcode/tag_node'
require 'ruby-bbcode/tag_collection'
require 'ruby-bbcode/bbtree'


module RubyBBCode
  include ::RubyBBCode::Tags

  # This method converts the given text (with BBCode tags) into a HTML representation
  # The escape_html parameter (default: true) escapes HTML tags that were present in the given text and therefore blocking (mallicious) HTML in the original text
  # The additional_tags parameter is used to add additional BBCode tags that should be accepted
  # The method paramter determines whether the tags parameter needs to be used to blacklist (when set to :disable) or whitelist (when not set to :disable) the list of BBCode tags
  def self.to_html(text, escape_html = true, additional_tags = {}, method = :disable, *tags)
    text = text.clone

    use_tags = determine_applicable_tags(additional_tags, method, *tags)

    @tag_sifter = TagSifter.new(text, use_tags, escape_html)

    @tag_sifter.process_text

    if @tag_sifter.invalid?
      raise @tag_sifter.errors.join(', ')   # We cannot convert to HTML if the BBCode is not valid!
    else
      @tag_sifter.bbtree.to_html(use_tags)
    end

  end

  # Returns true when valid, else returns array with error(s)
  def self.validity_check(text, additional_tags = {})
    @tag_sifter = TagSifter.new(text, @@tags.merge(additional_tags))

    @tag_sifter.process_text
    return @tag_sifter.errors if @tag_sifter.invalid?
    true
  end


  protected

  # This method provides the final set of bbcode tags, it merges the default tags with the given additional_tags
  # and blacklists(method = :disable) or whitelists the list of tags with the given tags parameter.
  def self.determine_applicable_tags(additional_tags, method, *tags)
    use_tags = @@tags.merge(additional_tags)
    if method == :disable then               # if method is set to :disable
      tags.each { |t| use_tags.delete(t) }   # blacklist (remove) the supplied tags
    else  # method is not :disable, but has any other value
      # Only use the supplied tags (whitelist)
      new_use_tags = {}
      tags.each { |t| new_use_tags[t] = use_tags[t] if use_tags.key?(t) }
      use_tags = new_use_tags
    end
    use_tags
  end

  def self.parse(text, tags)
    @tag_sifter = TagSifter.new(text, tags)

    @tag_sifter.process_text

    if @tag_sifter.invalid?
      @tag_sifter.errors
    else
      true
    end

  end

end

String.class_eval do
  # Convert a string with BBCode markup into its corresponding HTML markup
  def bbcode_to_html(escape_html = true, additional_tags = {}, method = :disable, *tags)
    RubyBBCode.to_html(self, escape_html, additional_tags, method, *tags)
  end

  # Replace the BBCode content of a string with its corresponding HTML markup
  def bbcode_to_html!(escape_html = true, additional_tags = {}, method = :disable, *tags)
    self.replace(RubyBBCode.to_html(self, escape_html, additional_tags, method, *tags))
  end

  # Deprecated!  Please use check_bbcode_validity (will be removed in version 0.1.0)
  # Check if string contains valid BBCode. Returns true when valid, else returns array with error(s)
  def is_valid_bbcode?
    # TODO:  add a puts "Warning:  This method has been deprecated, please use check_bbcode_validity which does the same thing but is more syntactical." or something
    check_bbcode_validity
  end

  # Check if string contains valid BBCode. Returns true when valid, else returns array with error(s)
  def check_bbcode_validity
    RubyBBCode.validity_check(self)
  end
end
