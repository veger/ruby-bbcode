require 'ruby-bbcode'
require "test/unit"

# This hack allows us to make all the private methods of a class public.  
class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    self.class_eval { public(*saved_private_instance_methods) }
    yield
    self.class_eval { private(*saved_private_instance_methods) }
  end
end


# This is for measuring memory usage...
def get_current_memory_usage
  `ps -o rss= -p #{Process.pid}`.to_i
end
