require_relative '../../lib/rackson'
require_relative '../../lib/rackson/object_mapper'

describe Rackson::ObjectMapper do
  let(:mapper) { Rackson::ObjectMapper.new }
  class DifferentFakeObject
    include Rackson
    json_property :baz, String

    attr_writer :baz
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
      expect(deserialized.something_optional).to be nil
      with_optional = mapper.deserialize '{"foo": "bar", "bar": {"baz":"another thing"}, "something_optional": "this now exists"}', FakeObject
      expect(with_optional.something_optional).to eq 'this now exists'
    end

    it 'exposes type mismatches' do
      expect do
        # DifferentFakeObject#baz is declared as a String above
        mapper.deserialize '{ "baz": 1 }', DifferentFakeObject
      end.to raise_error(/type mismatch between/)
    end

    it 'yells about missing keys' do
      expect do
        # FakeObject also requires `bar`
        mapper.deserialize '{ "foo": "bar" }', FakeObject
      end.to raise_error(/missing required key/)
    end
  end

  describe '#deserialize_into_array' do
    let(:json_string) { '[{ "baz": "foo" }]' }
    it 'deserializes into an array with #deserialize' do
      deserialized = mapper.deserialize(json_string, DifferentFakeObject)
      expect(deserialized).to be_a Array
      expect(deserialized.length).to eq 1
      expect(deserialized.first.baz).to eq 'foo'
    end
  end

  describe '#serialize' do
    let(:object) { object = DifferentFakeObject.new; object.baz = 'foo'; object }
    it 'only uses the fields declared as json_properties' do
      expect(mapper.serialize(object)).to eq '{"baz":"foo"}'
    end
  end
end
