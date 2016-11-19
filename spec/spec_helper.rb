require 'simplecov'
SimpleCov.start

require 'codecov'
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require 'jsonapi/serializable'

class Model
  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
end

class User < Model
  attr_accessor :id, :name, :address, :posts
end

class Post < Model
  attr_accessor :id, :title, :date, :author
end

class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'
  attributes :name, :address
  relationship :posts
end

class SerializablePost < JSONAPI::Serializable::Resource
  type 'posts'
  attributes :title, :date
  relationship :author
end
