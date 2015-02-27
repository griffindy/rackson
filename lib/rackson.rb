require 'rackson/property'
require 'rackson/version'

module Rackson
  def self.included(base)
    base.instance_variable_set(:@json_properties, [])
    base.extend ClassMethods
  end

  module ClassMethods
    def json_property(name, klass, options = {})
      property = Rackson::Property.new(name, klass, options)
      @json_properties << property
      define_method(property.name) do
        instance_variable_get("@#{property.name}")
      end
    end
  end

  def serializable_hash
    {}.tap do |result|
      self.class.instance_variable_get(:@json_properties).each do |property|
        result[property.name] = self.send(property.name)
      end
    end
  end
end
