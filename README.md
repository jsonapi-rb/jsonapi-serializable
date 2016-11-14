# jsonapi-serializable
Ruby gem for building [JSON API](http://jsonapi.org) resources to be rendered by
the [jsonapi-renderer](https://github.com/jsonapi-rb/renderer) gem.

## Status

[![Gem Version](https://badge.fury.io/rb/jsonapi-serializable.svg)](https://badge.fury.io/rb/jsonapi-serializable)
[![Build Status](https://secure.travis-ci.org/jsonapi-rb/serializable.svg?branch=master)](http://travis-ci.org/jsonapi-rb/serializable?branch=master)

## Table of Contents

  - [Installation](#installation)
  - [Usage](#usage)
    - [Example for Model-based Resources](#example-for-model-based-resources)
    - [Example for General Resources](#example-for-general-resources)
  - [Documentation](#documentation)
    - [`JSONAPI::Serializable::Resource` DSL](#jsonapiserializableresource-dsl)
    - [`JSONAPI::Serializable::Model` DSL](#jsonapiserializablemodel-dsl)
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

### Example for Model-based Resources

For resources that are simple representations of models, the DSL is simplified:

```ruby
class PostResource < JSONAPI::Serializable::Model
  type 'posts'

  attribute :title

  attribute :date do
    @model.created_at
  end

  has_one :author, UserResource do
    link(:self) do
      href @url_helper.link_for_rel('posts', @model.id, 'author')
      meta link_meta: 'some meta'
    end
    link(:related) { @url_helper.link_for_res('users', @model.author.id) }
    meta do
      { relationship_meta: 'some meta' }
    end
  end

  has_many :comments

  meta do
    { resource_meta: 'some meta' }
  end

  link(:self) do
    @url_helper.link_for_res('posts', @model.id)
  end
end
```

Then, build your resources from your models and render them:
```ruby
# post = some post model
# UrlHelper is some helper class
resource = PostResource.new(model: post, url_helper: UrlHelper)
document = JSONAPI.render(data: resource)
```

### Example for General Resources

In case your resource is not a simple representation of one of your models,
the more general `JSONAPI::Serializable::Resource` class can be used.

```ruby
class PostResource < JSONAPI::Serializable::Resource
  type 'posts'

  id do
    @post.id.to_s
  end

  attribute :title do
    @post.title
  end

  attribute :date do
    @post.date
  end

  relationship :author do
    link(:self) do
      href @url_helper.link_for_rel('posts', @post.id, 'author')
      meta link_meta: 'some meta'
    end
    link(:related) { @url_helper.link_for_res('users', @post.author.id) }
    data do
      if @post.author.nil?
        nil
      else
        UserResource.new(user: @post.author, url_helper: @url_helper)
      end
    end
    meta do
      { relationship_meta: 'some meta' }
    end
  end

  meta do
    { resource_meta: 'some meta' }
  end

  link(:self) do
    @url_helper.link_for_res('posts', @post.id)
  end
end
```
Finally, build your resources from your models and render them:
```ruby
# post = some post model
# UrlHelper is some helper class
resource = PostResource.new(post: post, url_helper: UrlHelper)
document = JSONAPI.render(data: resource)
```

## Documentation

### `JSONAPI::Serializable::Resource` DSL

+ `#initialize(hash)`

All the values of the hash are made available during serialization as instance
variables within all DSLs.

Example:
```ruby
SerializablePost.new(post: post, url_helper: url_helper)
# => You can then use @post and @url_helper from within the DSL.
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
      SerializableComment.new(comment: c, url_helper: @url_helper)
    end
  end
  link :self do
    @url_helper.link_for_post_comments(post_id: @post.id)
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

### `JSONAPI::Serializable::Model` DSL

This class is a subclass of `JSONAPI::Serializable::Resource` with a more
convenient DSL tailored for resources that are direct representation of some
business models.

+ `#initialize(hash)`

See `JSONAPI::Serializable::Resource` DSL.

The model is expected to be provided in the hash with the key `:model`.

+ `::type(value = nil, &block)`

See `JSONAPI::Serializable::Resource` DSL.

+ `::id(&block)`

See `JSONAPI::Serializable::Resource` DSL.

Defaults to:
```ruby
id { @model.id }
```

+ `::attribute(key, &block)`

See `JSONAPI::Serializable::Resource` DSL.

Defaults to the following when no block is provided:
```ruby
attribute key do
  @model.public_send(key)
end
```

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

See `JSONAPI::Serializable::Resource` DSL.

+ `::link(key, &block)`

See `JSONAPI::Serializable::Resource` DSL.

+ `::meta(value = nil, &block)`

See `JSONAPI::Serializable::Resource` DSL.

### `JSONAPI::Serializable::Relationship` DSL

+ `::data(&block)`

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

Note: It is possible to avoid this `nil` check by defining the `nil?` method on
the `SerializableUser` class. In that case, the following is enough:
```ruby
data { @post.author }
```

+ `::link(key, &block)`

Define a relationship-level link.

See `JSONAPI::Serializable::Resource` DSL.

+ `::meta(value = nil, &block)`

Define some relationship-level meta member.

See `JSONAPI::Serializable::Resource` DSL.

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
