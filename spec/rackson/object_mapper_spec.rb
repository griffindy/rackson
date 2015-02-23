require_relative '../../lib/rackson'
require_relative '../../lib/rackson/object_mapper'

describe Rackson::ObjectMapper do
  let(:mapper) { Rackson::ObjectMapper.new }
  class DifferentFakeObject
    include Rackson
    json_property :baz, String
  end

  class FakeObject
    include Rackson
    json_property :foo, String
    json_property :bar, DifferentFakeObject
    json_property :something_optional, String, optional: true
  end

  describe '#deserialize' do
    let(:json_string) { '{"foo": "bar", "bar": {"baz":"another thing"}}' }
    let(:deserialized) { mapper.deserialize(json_string, FakeObject) }

    it 'returns an object of the given class' do
      expect(deserialized).to be_a FakeObject
    end

    it 'sets the appropriate values' do
      expect(deserialized.foo).to eq 'bar'
    end

    it 'understands non JSON POROs' do
      expect(deserialized.bar.baz).to eq 'another thing'
    end

    it 'understands optional properties' do

    end
  end
end
