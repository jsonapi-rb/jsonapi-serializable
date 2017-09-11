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

ATTR_NAMES = (1..100).map { |i| "attr_#{i}" }

class User < Model
  attr_accessor :id, :posts
end

class Post < Model
  attr_accessor :id
  attr_accessor(*ATTR_NAMES)
end

class SerializableUser < JSONAPI::Serializable::Resource
  type 'users'
  relationship :posts, class: 'SerializablePost'
end

class SerializablePost < JSONAPI::Serializable::Resource
  type 'posts'
  attributes(*ATTR_NAMES)
end

posts = (1..1000).map do |i|
  attrs = ATTR_NAMES.each_with_object({}) { |k, h| h[k] = "val #{i}" }
  Post.new(attrs.merge(id: i))
end

user = User.new(id: 'foo', posts: posts)

class Cache
  def initialize
    @cache = {}
  end

  def fetch_multi(keys)
    keys.each_with_object({}) do |k, h|
      @cache[k] = yield(k) unless @cache.key?(k)
      h[k] = @cache[k]
    end
  end
end

Benchmark.ips do |x|
  cache = Cache.new
  renderer = JSONAPI::Serializable::Renderer.new
  x.report('No cache') do
    renderer.render(user, class: { User: SerializableUser, Post: SerializablePost }, include: [:posts])
  end
  x.report('Cache') do
    renderer.render(user, class: { User: SerializableUser, Post: SerializablePost }, include: [:posts], cache: cache)
  end
  x.compare!
end
