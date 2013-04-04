module RubyBBCode
  # This class holds TagNodes and helps build them into html when the time comes.  It's really just a simple array, with the addition of the #to_html method
  class TagCollection < Array
    
    def to_html(tags)
      html_string = ""
      self.each do |node|
        if node.type == :tag
          t = HtmlTemplate.new node
          
          t.inlay_between_text!
          
          if node.allow_tag_param? and node.param_set?
            t.inlay_inline_params!
          elsif node.allow_tag_param? and node.param_not_set?
            t.remove_unused_tokens!
          end
          
          html_string += t.opening_html
          
          # invoke "recursive" call if this node contains child nodes
          html_string += node.children.to_html(tags) if node.has_children?
          
          t.inlay_closing_html!
          
          html_string += t.closing_html
        elsif node.type == :text
          html_string += node[:text] unless node[:text].nil?
        end
      end
      
      html_string
    end
    
    
    
    # This class is designed to help us build up the HTML data.  It starts out as a template such as...
    #   @opening_html = '<a href="%url%">%between%'
    #   @closing_html = '</a>'
    # and then slowly turns into...
    #   @opening_html = '<a href="http://www.blah.com">cool beans'
    #   @closing_html = '</a>'
    # TODO: Think about creating a separate file for this or something... maybe look into folder structures cause this project
    # got huge when I showed up.  
    class HtmlTemplate
      attr_accessor :opening_html, :closing_html
      
      def initialize(node)
        @node = node
        @tag_definition = node.definition # tag_definition
        @opening_html = node.definition[:html_open].dup
        @closing_html = node.definition[:html_close].dup
      end
      
      def inlay_between_text!
        @opening_html.gsub!('%between%',@node[:between]) if between_text_goes_into_html_output_as_param?  # set the between text to where it goes if required to do so...
      end
      
      def inlay_inline_params!
        # Get list of paramaters to feed
        match_array = @node[:params][:tag_param].scan(@tag_definition[:tag_param])[0]
        
        # for each parameter to feed
        match_array.each.with_index do |match, i|
          if i < @tag_definition[:tag_param_tokens].length
            
            # Substitute the %param% keyword for the appropriate data specified
            @opening_html.gsub!("%#{@tag_definition[:tag_param_tokens][i][:token].to_s}%", 
                      @tag_definition[:tag_param_tokens][i][:prefix].to_s + 
                        match + 
                        @tag_definition[:tag_param_tokens][i][:postfix].to_s)
          end
        end
      end
      
      def inlay_closing_html!
        @closing_html.gsub!('%between%',@node[:between]) if @tag_definition[:require_between]
      end
      
      def remove_unused_tokens!
        @tag_definition[:tag_param_tokens].each do |token|
          @opening_html.gsub!("%#{token[:token]}%", '')
        end
      end
      
      private
      
      def between_text_goes_into_html_output_as_param?
        @tag_definition[:require_between]
      end
    end
    
  end 
end