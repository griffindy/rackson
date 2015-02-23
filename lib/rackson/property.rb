module Rackson
  class Property
    attr_reader :name, :klass

    def initialize(name, klass, options)
      @name = name
      @klass = klass
      @options = options
    end

    def required?
      !@options[:optional]
    end
  end
end
