# jsonapi-serializable
Ruby gem for building and rendering [JSON API](http://jsonapi.org).

## Status

[![Gem Version](https://badge.fury.io/rb/jsonapi-serializable.svg)](https://badge.fury.io/rb/jsonapi-serializable)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/serializable.svg?branch=master)](http://travis-ci.org/jsonapi-rb/serializable?branch=master)
[![codecov](https://codecov.io/gh/jsonapi-rb/serializable/branch/master/graph/badge.svg)](https://codecov.io/gh/jsonapi-rb/serializable)
[![Gitter chat](https://badges.gitter.im/gitterHQ/gitter.png)](https://gitter.im/jsonapi-rb/Lobby)

## Table of Contents

  - [Installation](#installation)
  - [Usage](#usage)
  - [Documentation](#documentation)
    - [`JSONAPI::Serializable::Resource` DSL](#jsonapiserializableresource-dsl)
    - [`JSONAPI::Serializable::Relationship` DSL](#jsonapiserializablerelationship-dsl)
    - [`JSONAPI::Serializable::Link` DSL](#jsonapiserializablelink-dsl)
    - [`JSONAPI::Serializable::Error` DSL](#jsonapiserializableerror-dsl)
  - [License](#license)

## Installation
```ruby
# In Gemfile
gem 'jsonapi-serializable'
```
then
```
$ bundle
```
or manually via
```
$ gem install jsonapi-serializable
```

## Usage

First, require the gem:
```ruby
require 'jsonapi/serializable'
```

Then, define some resource classes:

```ruby
class PostResource < JSONAPI::Serializable::Resource
  type 'posts'

  attribute :title

  attribute :date do
    @object.created_at
  end

  has_one :author, 'V2::SerializableUser' do
    link(:self) do
      href @url_helpers.link_for_rel('posts', @object.id, 'author')
      meta link_meta: 'some meta'
    end
    link(:related) { @url_helpers.link_for_res('users', @object.author.id) }
    meta do
      { relationship_meta: 'some meta' }
    end
  end

  has_many :comments

  meta do
    { resource_meta: 'some meta' }
  end

  link(:self) do
    @url_helpers.link_for_res('posts', @object.id)
  end
end
```

Then, render your resources:
```ruby
# `post` is some `Post` object
# `UrlHelpers` is some helper class
document = JSONAPI::Serializable::Renderer.render(
  post,
  expose: { url_helpers: UrlHelpers.new }
)
```

## Documentation

### `JSONAPI::Serializable::AbstractResource` DSL

+ `#initialize(hash)`

All the values of the hash are made available during serialization as instance
variables within all DSLs.

Example:
```ruby
SerializablePost.new(post: post, url_helpers: url_helpers)
# => You can then use @post and @url_helpers from within the DSL.
```

+ `::type(value = nil, &block)`

Define the type of the resource, either statically, or dynamically as the
return value of the block.

+ `::id(&block)`

Define the id of the resource.

Example:
```ruby
id { @post.id }
```

+ `::attribute(key, &block)`

Define an attribute of the resource.

Example:
```ruby
attribute(:title) { @post.title }
```

+ `::relationship(key, &block)`

Define a relationship of the resource. The block can contain any instruction of
the [`JSONAPI::Serializable::Relationship` DSL](#jsonapiserializablerelationship-dsl).

Example:
```ruby
relationship :comments do
  data do
    @post.comments.map do |c|
      SerializableComment.new(comment: c, url_helpers: @url_helpers)
    end
  end
  link :self do
    @url_helpers.link_for_post_comments(post_id: @post.id)
  end
  meta do
    { count: @post.comments.count }
  end
end
```

+ `::link(key, &block)`

Define a resource-level link. The block can either return a string or contain
any instruction of the [`JSONAPI::Serializable::Link` DSL](#jsonapiserializablelink-dsl).

Example:
```ruby
link :self do
  "http://api.example.com/posts/#{@post.id}"
end
```

+ `::meta(value = nil, &block)`

Define a resource-level meta member. The value can either be provided
statically, or dynamically as the return value of a block.

Examples:
```ruby
meta(experimental: true)
```
```ruby
meta do
  { remaining_time: @post.remaining_time }
end
```

### `JSONAPI::Serializable::Resource` DSL

This class is a subclass of `JSONAPI::Serializable::AbstractResource` with a more
convenient DSL tailored for resources that are direct representation of some
business models.

+ `#initialize(hash)`

See `JSONAPI::Serializable::AbstractResource` DSL.

The model is expected to be provided in the hash with the key `:model`.

+ `::type(value = nil, &block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

+ `::id(&block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

Defaults to:
```ruby
id { @model.id }
```

+ `::attribute(key, &block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

Defaults to the following when no block is provided:
```ruby
attribute key do
  @model.public_send(key)
end
```

+ `::attributes(*keys)`

Define multiple attributes.

+ `::has_one(key, resource_klass = nil, &block)`

Define a `has_one` relationship on the resource.

The serializable class for the related resource can be explicitly stated as the
second parameter, but when omitted it will be infered from the related
resource's class name.

When no block is provided, the value of the relationship defaults to
`resource_klass.new(model: @model.public_send(key))`.

+ `::has_many(key, resource_klass = nil, &block)`

Define a `has_many` relationship on the resource.

The serializable class for the related resources can be explicitly stated as the
second parameter, but when omitted it will be infered from the related
resources' class names.

When no block is provided, the value of the relationship defaults to:
```ruby
@model.public_send(key).map do |r|
  resource_klass.new(model: r)
end
```

+ `::relationship(key, &block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

+ `::link(key, &block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

+ `::meta(value = nil, &block)`

See `JSONAPI::Serializable::AbstractResource` DSL.

### `JSONAPI::Serializable::Relationship` DSL

+ `::data(resource_class = nil, &block)`

NOTE: This section is outdated. It is still valid, but the data method is
now much more flexible.

Defines the related serializable resources for the relationship.

Example:
```ruby
data do
  if @post.author.nil?
    nil
  else
    SerializableUser.new(user: @post.author)
  end
end
```

+ `::linkage(&block)`

Explicitly define linkage data (optional).

+ `::link(key, &block)`

Define a relationship-level link.

See `JSONAPI::Serializable::AbstractResource` DSL.

+ `::meta(value = nil, &block)`

Define some relationship-level meta member.

See `JSONAPI::Serializable::AbstractResource` DSL.

### `JSONAPI::Serializable::Link` DSL

+ `::href(value = nil, &block)`

Define the href member for the link, either directly, or dynamically as the
return value of a block.

+ `::meta(value = nil, &block)`

Define the meta member for the link, either directly, or dynamically as the
return value of a block.

### `JSONAPI::Serializable::Error` DSL

+ `::id(value = nil, &block)`

+ `::status(value = nil, &block)`

+ `::code(value = nil, &block)`

+ `::title(value = nil, &block)`

+ `::detail(value = nil, &block)`

+ `::meta(value = nil, &block)`

+ `::link(key, &block)`

+ `::source(&block)`

## License

jsonapi-serializable is released under the [MIT License](http://www.opensource.org/licenses/MIT).
