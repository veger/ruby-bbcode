module RubyBBCode
  class BBTree
    def initialize(hash = {})
      @hash = hash
    end
    
    def [](key)
      @hash[key]
    end
    
    def []=(key, value)
      @hash[key] = value
    end
    
    def requires_param_but_none_specified_in_tag_param?
      (@hash[:params].nil? or @hash[:params][:tag_param].nil?)
    end
    
  end
end