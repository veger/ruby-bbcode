module RubyBBCode::Templates
  # This class is designed to help us build up the (original) BBCode annotated with the error information.
  # It starts out as a template such as...
  #   @opening_part = '[url=%quick_param%]
  #   @closing_part = '[/url]'
  # and then slowly turns into...
  #   @opening_part = '[url=http://www.blah.com"]cool beans'
  #   @closing_part = '[/url]'
  class BBCodeErrorsTemplate
    attr_accessor :opening_part, :closing_part

    def initialize(node)
      @node = node
      @tag_definition = node.definition # tag_definition
      @opening_part = "[#{node[:tag]}#{node.allow_quick_param? ? '%quick_param%' : ''}]"
      @closing_part = "[/#{node[:tag]}]"
    end

    def self.convert_text(text)
      # Keep the text as it was
      text
    end

    def inlay_between_text!
      # Set the between text between the tags again, if required to do so...
      @opening_part << @node[:between] if @tag_definition[:require_between]
    end

    def inlay_quick_param!
      if @tag_definition[:allow_quick_param_between] and @node[:params][:quick_param] == @node[:between]
        # Place tag parameter between the tags, which was the case since quick_param == between
        @opening_part.gsub!('%quick_param%','')
      else
        # Fill in provided tag parameter
        @opening_part.gsub!('%quick_param%',"=#{@node[:params][:quick_param]}")
      end
    end

    def inlay_params!
      # Iterate over known tokens and fill in their values, if provided
      @tag_definition[:param_tokens].each do |token|
        # Use %quick_param% to insert the parameters and their values (and re-add %quick_param%)
        @opening_part.gsub!('%quick_param%', " #{token[:token]}=#{@node[:params][token[:token]]}%quick_param%") unless @node[:params][token[:token]].nil?
      end
    end

    def inlay_closing_part!
      @closing_part.gsub!('%between%',@node[:between]) if @tag_definition[:require_between]
    end

    def remove_unused_tokens!
      @opening_part.gsub!('%quick_param%', '')
    end
  end
end
