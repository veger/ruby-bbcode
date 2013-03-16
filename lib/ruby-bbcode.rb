require 'pry'

require 'tags/tags'
require 'ruby-bbcode/debugging'
require 'ruby-bbcode/tag_info'
require 'ruby-bbcode/tag_sifter'
require 'ruby-bbcode/tag_node'
require 'ruby-bbcode/bbtree'


module RubyBBCode
  include BBCode::Tags

  def self.to_html(text, escape_html = true, additional_tags = {}, method = :disable, *tags)
    # We cannot convert to HTML if the BBCode is not valid!
    text = text.clone
    use_tags = @@tags.merge(additional_tags)

    if method == :disable then
      tags.each { |t| use_tags.delete(t) }
    else
      new_use_tags = {}
      tags.each { |t| new_use_tags[t] = use_tags[t] if use_tags.key?(t) }
      use_tags = new_use_tags
    end

    if escape_html
      text.gsub!('<', '&lt;')
      text.gsub!('>', '&gt;')
    end

    valid = parse(text, use_tags)
    raise valid.join(', ') if valid != true

    bbtree_to_html(@tag_sifter.bbtree[:nodes], use_tags)
  end

  def self.is_valid?(text, additional_tags = {})
    parse(text, @@tags.merge(additional_tags));
  end

  def self.tag_list
    @@tags
  end

  protected
  def self.parse(text, tags = {})
    tags = @@tags if tags == {}
    
    @tag_sifter = TagSifter.new(text, tags)
    
    @tag_sifter.process_text
    
    if @tag_sifter.invalid?
      @tag_sifter.errors 
    else
      true
    end
    
  end


  def self.bbtree_to_html(node_list, tags = {})
    tags = @@tags if tags == {}
    
    text = ""
    node_list.each do |node|
      if node[:is_tag]
        tag = tags[node[:tag]]
        t = tag[:html_open].dup
        t.gsub!('%between%', node[:between]) if tag[:require_between]
        if tag[:allow_tag_param]
          if node[:params] and !node[:params][:tag_param].blank?
            match_array = node[:params][:tag_param].scan(tag[:tag_param])[0]
            index = 0
            match_array.each do |match|
              if index < tag[:tag_param_tokens].length
                t.gsub!("%#{tag[:tag_param_tokens][index][:token].to_s}%", tag[:tag_param_tokens][index][:prefix].to_s+match+tag[:tag_param_tokens][index][:postfix].to_s)
                index += 1
              end
            end
          else
            # Remove unused tokens
            tag[:tag_param_tokens].each do |token|
              t.gsub!("%#{token[:token]}%", '')
            end
          end
        end

        text += t
        text += bbtree_to_html(node[:nodes], tags) if node[:nodes].length > 0
        t = tag[:html_close]
        t.gsub!('%between%', node[:between]) if tag[:require_between]
        text += t
      else
        text += node[:text] unless node[:text].nil?
      end
    end
    text
  end
  
  # Parses a youtube video url and extracts the ID  
  def self.parse_youtube_id(url)
    url =~ /[vV]=([^&]*)/
    id = $1
    
    if id.nil?
      # when there is no match for v=blah, then maybe they just 
      # provided us with the ID the way the system used to work... 
      # just "E4Fbk52Mk1w"
      return url  
    else
      # else we got a match for an id and we can return that ID...
      return id
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

  # Check if string contains valid BBCode. Returns true when valid, else returns array with error(s)
  def is_valid_bbcode?
    RubyBBCode.is_valid?(self)
  end
end
