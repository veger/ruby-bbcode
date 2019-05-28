require 'json'

module RubyBBCode::Templates
  # This class is designed to help us build up the (original) BBCode annotated with the error information.
  # It starts out as a template such as...
  #   @opening_part = '[url=%param%]
  #   @closing_part = '[/url]'
  # and then slowly turns into...
  #   @opening_part = '[url=http://www.blah.com"]cool beans'
  #   @closing_part = '[/url]'
  class BBCodeErrorsTemplate
    attr_accessor :opening_part

    def initialize(node)
      @node = node
      @tag_definition = node.definition # tag_definition
      @opening_part = "[#{node[:tag]}#{node.allow_params? ? '%param%' : ''}]" + add_whitespace(node[:opening_whitespace])
      @opening_part = "<span class='bbcode_error' #{BBCodeErrorsTemplate.error_attribute(@node[:errors])}>#{@opening_part}</span>" unless @node[:errors].empty?
      @closing_part = "[/#{node[:tag]}]" + add_whitespace(node[:closing_whitespace])
    end

    def self.convert_text(node, _parent_node)
      # Keep the text as it was
      return "<span class='bbcode_error' #{error_attribute(node[:errors])}>#{node[:text]}</span>" unless node[:errors].empty?

      node[:text]
    end

    def inlay_between_text!
      # Set the between text between the tags again, if required to do so...
      @opening_part << get_between
    end

    def inlay_params!
      # Iterate over known tokens and fill in their values, if provided
      @tag_definition[:param_tokens].each do |token|
        # Use %param% to insert the parameters and their values (and re-add %param%)
        param_value = @node[:params][token[:token]]
        @opening_part.gsub!('%param%', " #{token[:token]}=#{param_value}%param%") unless param_value.nil?
      end
    end

    def inlay_closing_part!; end

    def remove_unused_tokens!
      @opening_part.gsub!('%param%', '')
    end

    def closing_part
      @node[:closed] == false ? '' : @closing_part
    end

    private

    def add_whitespace(whitespace)
      whitespace || ''
    end

    def get_between
      return @node[:between] if @tag_definition[:require_between] && @node[:between]

      ''
    end

    def self.error_attribute(errors)
      # Escape (double) quotes so the JSON can be generated properly (and parsed properly by JavaScript)
      escapedErrors = errors.map { |error| error.gsub('"', '&quot;').gsub("'", '&#39;') }
      "data-bbcode-errors='#{JSON.fast_generate(escapedErrors)}'"
    end
  end
end
