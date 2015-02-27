require 'json'

module Rackson
  class ObjectMapper
    def deserialize(input, klass)
      case input
      when String
        deserialize(JSON.parse(input), klass)
      when Hash
        deserialize_from_hash(input, klass)
      when Array
        deserialize_into_array(input, klass)
      end
    end

    def deserialize_from_hash(hash, klass)
      klass.new.tap do |instance|
        klass.instance_variable_get(:@json_properties).each do |property|
          value = generate_value property, hash
          instance.instance_variable_set("@#{property.name}", value)
        end
      end
    end

    def deserialize_into_array(array, klass)
      array.map do |value|
        deserialize(value, klass)
      end
    end

    private

    def generate_value(property, json_hash)
      value_from_json = json_hash.fetch(property.name.to_s) do |key|
        if property.required?
          raise "missing required key #{key}"
        end
      end

      case value_from_json
      # already cast to the appropriate class
      when property.klass
        value_from_json
      # needs to be deserialized into its own object
      when Hash
        deserialize_from_hash(value_from_json, property.klass)
      when NilClass
        nil
      else
        raise "type mismatch between #{value_from_json.inspect} (a #{value_from_json.class}) and #{property.klass}"
      end
    end
  end
end
