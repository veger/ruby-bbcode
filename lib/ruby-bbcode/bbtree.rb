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
    
    
  end
end