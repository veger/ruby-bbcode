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
    attr_accessor :opening_part, :closing_part

    def initialize(node)
      @node = node
      @tag_definition = node.definition # tag_definition
      @opening_part = "[#{node[:tag]}#{node.allow_params? ? '%param%' : ''}]"
      unless @node[:errors].empty?
        @opening_part = "<span class='bbcode_error' #{BBCodeErrorsTemplate.error_attribute(@node[:errors])}>#{@opening_part}</span>"
      end
      @closing_part = "[/#{node[:tag]}]"
    end

    def self.convert_text(node)
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
        @opening_part.gsub!('%param%', " #{token[:token]}=#{@node[:params][token[:token]]}%param%") unless @node[:params][token[:token]].nil?
      end
    end

    def inlay_closing_part!
    end

    def remove_unused_tokens!
      @opening_part.gsub!('%param%', '')
    end

    private

      def get_between
        return @node[:between] if @tag_definition[:require_between] and @node[:between]
        ''
      end

      def self.error_attribute(errors)
        "data-bbcode-errors='#{JSON.fast_generate(errors)}'"
      end
  end
end
