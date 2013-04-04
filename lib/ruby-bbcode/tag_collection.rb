module RubyBBCode
  # This class builds objects that hold TagNodes.  It's really just a simple array, with the addition of the #to_html method
  class TagCollection < Array
    
    class HtmlTemplate
      
      def initialize(tag_definition, node)
        @tag_definition = tag_definition
        @opening_html = tag_definition[:html_open].dup
        @closing_html = tag_definition[:html_close].dup
        @node = node
      end
      
      def inlay_between_text!
        @opening_html.gsub!('%between%',@node[:between]) if between_text_goes_into_html_output_as_param?  # set the between text to where it goes if required to do so...
      end
      
      def inlay_inline_params!
        # TODO:  refactor this into #...
        # Get list of paramaters to feed
        match_array =@node[:params][:tag_param].scan(@tag_definition[:tag_param])[0]
        
        # for each parameter to feed
        match_array.each.with_index do |match, i|
          if i < @tag_definition[:tag_param_tokens].length
            
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
      
      
      def opening_html
        @opening_html
      end
      
      def closing_html
        @closing_html
      end
      
      def +(s)
        @opening_html + s
      end
      
      private
      
      def between_text_goes_into_html_output_as_param?
        @tag_definition[:require_between]
      end
    end
    
    
    
    def to_html(tags)
      html_string = ""
      self.each do |node|
        if node.type == :tag
          @tag_definition = tags[node[:tag]]
          
          t = HtmlTemplate.new @tag_definition, node
          
          t.inlay_between_text!
          
          if @tag_definition[:allow_tag_param] and node.param_set?
            t.inlay_inline_params!
          elsif @tag_definition[:allow_tag_param] and node.param_not_set?
            t.remove_unused_tokens!
          end
          
          html_string += t.opening_html
          
          # invoke recursive call if this node contains child nodes
          html_string += node[:nodes].to_html(tags) if node.has_children?
          
          t.inlay_closing_html!
          
          html_string += t.closing_html
        elsif node.type == :text
          html_string += node[:text] unless node[:text].nil?
        end
      end
      
      html_string
    end
    
    # TODO:  Deleteme, I got moved
    def between_text_goes_into_html_output_as_param?
      @tag_definition[:require_between]
    end
    
  end 
end