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
    
    def param_not_set?
      (@hash[:params].nil? or @hash[:params][:tag_param].nil?)
    end
    
  end
end