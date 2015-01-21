require 'ruby-bbcode/templates/html_template'
require 'ruby-bbcode/templates/bbcode_errors_template'

module RubyBBCode
  # This class holds TagNode instances and helps converting them into code (using the provided template) when the time comes.
  class TagCollection < Array
    # Convert nodes to HTML
    def to_html(tags)
      to_code(tags, RubyBBCode::Templates::HtmlTemplate)
    end

    # Convert nodes to BBCode (with error information)
    def to_bbcode(tags)
      to_code(tags, RubyBBCode::Templates::BBCodeErrorsTemplate)
    end

    # This method is vulnerable to stack-level-too-deep scenarios where >=1,200 tags are being parsed.
    # But that scenario can be mitigated by splitting up the tags.  bbtree = { :nodes => [900tags, 1000tags] }, the work
    # for that bbtree can be split up into two passes, do the each node one at a time.  I'm not coding that though, it's pointless, just a thought though
    def to_code(tags, template)
      html_string = ""
      self.each do |node|
        if node.type == :tag
          t = template.new node

          t.inlay_between_text!

          if node.allow_params?
            if node.params_set?
              t.inlay_params!
            end
            t.remove_unused_tokens!
          end

          html_string << t.opening_part

          # invoke "recursive" call if this node contains child nodes
          html_string << node.children.to_code(tags, template) if node.has_children?      # FIXME:  Don't use recursion, it can lead to stack-level-too-deep errors for large volumes?

          t.inlay_closing_part!

          html_string << t.closing_part
        elsif node.type == :text
          html_string << template.convert_text(node[:text])
        end
      end

      html_string
    end
  end
end