module RubyBBCode::Templates
  # This class is designed to help us build up the HTML data.  It starts out as a template such as...
  #   @opening_part = '<a href="%url%">%between%'
  #   @closing_part = '</a>'
  # and then slowly turns into...
  #   @opening_part = '<a href="http://www.blah.com">cool beans'
  #   @closing_part = '</a>'
  class HtmlTemplate
    attr_accessor :opening_part, :closing_part

    def initialize(node)
      @node = node
      @tag_definition = node.definition
      @opening_part = node.definition[:html_open] + add_whitespace(:opening_whitespace)
      @closing_part = node.definition[:html_close] + add_whitespace(:closing_whitespace)
    end

    # Newlines are converted to html <br /> syntax before being returned.
    def self.convert_text(node, parent_node)
      return '' if node[:text].nil?

      text = node[:text]
      whitespace = ''

      if !parent_node.nil? && parent_node.definition[:block_tag]
        # Strip EOL whitespace, so it does not get converted
        text.scan(/(\s+)$/) do |result|
          whitespace = result[0]
          text = text[0..-result[0].length - 1]
        end
      end
      convert_newlines(text) + whitespace
    end

    def inlay_between_text!
      @opening_part.gsub!('%between%', format_between) if between_text_as_param?
    end

    def inlay_params!
      # Iterate over known tokens and fill in their values, if provided
      @tag_definition[:param_tokens].each do |token|
        param_value = @node[:params][token[:token]] || token[:default]
        param_value = CGI.escape(param_value) if token[:uri_escape]
        @opening_part.gsub!("%#{token[:token]}%", "#{token[:prefix]}#{param_value}#{token[:postfix]}") unless param_value.nil?
      end
    end

    def inlay_closing_part!
      @closing_part.gsub!('%between%', format_between) if between_text_as_param?
    end

    def remove_unused_tokens!
      @tag_definition[:param_tokens].each do |token|
        @opening_part.gsub!("%#{token[:token]}%", '')
      end
    end

    def self.convert_newlines(text)
      text.gsub("\r\n", "\n").gsub("\n", "<br />\n")
    end

    private

    def add_whitespace(key)
      whitespace = @node[key]
      return '' if whitespace.nil?

      whitespace = HtmlTemplate.convert_newlines(whitespace) unless @tag_definition[:block_tag]
      whitespace
    end

    # Return true if the between text is needed as param
    def between_text_as_param?
      @tag_definition[:require_between]
    end

    def format_between
      @node[:between] || ''
    end
  end
end
