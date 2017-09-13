require 'rubygems'
require 'bundler/setup'

require 'benchmark/ips'

require 'json'
require 'jsonapi/serializable'

class Model
  def initialize(params = {})
    params.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
end

ATTR_NAMES = (1..1).map { |i| "attr_#{i}" }

class User < Model
  attr_accessor :id, :posts
end

class Post < Model
  attr_accessor :id
  attr_accessor(*ATTR_NAMES)
end

class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'
  has_many :posts
end

class SerializablePost < JSONAPI::Serializable::Resource
  type 'posts'
  attributes(*ATTR_NAMES)
end

posts = (1..1).map do |i|
  attrs = ATTR_NAMES.each_with_object({}) { |k, h| h[k] = "val #{i}" }
  Post.new(attrs.merge(id: i))
end

user = User.new(id: 'foo', posts: posts)

Benchmark.ips do |x|
  renderer = JSONAPI::Serializable::Renderer.new

  x.report('current') do
    renderer.render(user, class: { User: SerializableUser, Post: SerializablePost }, include: [:posts])
  end

  x.hold!('benchmark.tmp')

  x.report('master') do
    renderer.render(user, class: { User: SerializableUser, Post: SerializablePost }, include: [:posts])
  end

  x.compare!
end
