# Rackson

Rackson serves to turn JSON into ruby objects. Where Rackson differs from other
libraries is that the classes are expected to be already defined so that if you
use the wrong input or try to call a method that doesn't exist it will raise an
exception as soon as possible

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rackson'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rackson

## Usage

Let's just start with a very simple example


```ruby
class Foo
  include Rackson
  json_property :bar, String
end

mapper = Rackson::ObjectMapper.new
foo = mapper.deserialize('{ "bar": "value" }', Foo)
foo.bar
# 'value'
```

As you can see after including `Rackson` the class now has access to a
`json_property` method which defines a new property. The first argument is the
key, the second is the type. This way if you pass something *not* a string you
will get an exception when trying to deserialize instead of later. The class can
be whatever you want:

```ruby
class Inner
  include Rackson
  json_property :foo, String
end

class Outer
  include Rackson
  json_property :inner, Inner
end

mapper = Rackson::ObjectMapper.new
outer = mapper.deserialize('{ "outer": { "foo": "bar" }}', Outer)
outer.inner.foo
# 'bar'
```

Unless specified otherwise, all properties are required:

```ruby
class Foo
  include Rackson
  json_property :foo, String
  json_property :bar, String
end

mapper = Rackson::ObjectMapper.new
outer = mapper.deserialize('{ "foo": "this is foo" }', Foo)
# RuntimeError: missing required key bar
```

However, properties are easily marked as optional:

```ruby
class Foo
  include Rackson
  json_property :foo, String
  json_property :bar, String, optional: true
end

mapper = Rackson::ObjectMapper.new
outer = mapper.deserialize('{ "foo": "this is foo" }', Foo)
outer.bar
# nil
```


## Contributing

1. Fork it ( https://github.com/griffindy/rackson/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
