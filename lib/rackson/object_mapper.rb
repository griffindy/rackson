require 'json'

module Rackson
  class DeserializationError < StandardError; end
  class SerializationError < StandardError; end

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

    def serialize(input)
      JSON.dump(input.serializable_hash)
    end

    def deserialize_from_hash(hash, klass)
      # determine whether we can use the class's initializer.
      # if the arity of initialize is 0, that means it takes no
      # arguments. if the arity is -1 that means there are arguments,
      # but none are required.
      #
      # if we can't use the class's initialize method we use `allocate`,
      # which allocates memory for the object, but does not call the
      # class's initializer.
      #
      # TODO: optionally log a warning when we need to call `allocate`?
      # TODO: if performance is a problem, we could memoize the arity
      #       of each class in a Hash.
      initialize_arity = klass.instance_method(:initialize).arity
      i = if initialize_arity == -1 || initialize_arity == 0
            klass.new
          else
            klass.allocate
          end
      i.tap do |instance|
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
          raise Rackson::DeserializationError, "missing required key #{key}"
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
