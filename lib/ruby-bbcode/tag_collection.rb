module RubyBBCode
  # This class builds objects that hold TagNodes.  It's really just a simple array, with the addition of the #to_html method
  class TagCollection < Array
    #attr_accessor :nodes
    
    def to_html(tags = {})
      tags = @dictionary if tags == {}
      
      text = ""
      self.each do |node|
        if node[:is_tag]
          tag = tags[node[:tag]]
          t = tag[:html_open].dup
          t.gsub!('%between%', node[:between]) if tag[:require_between]
          if tag[:allow_tag_param]
            if node[:params] and !node[:params][:tag_param].nil?
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
          text += node[:nodes].to_html(tags) if node[:nodes].length > 0
          t = tag[:html_close]
          t.gsub!('%between%', node[:between]) if tag[:require_between]
          text += t
        else
          text += node[:text] unless node[:text].nil?
        end
      end
      text
      
    end
  end 
end