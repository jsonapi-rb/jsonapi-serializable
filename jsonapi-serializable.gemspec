version = File.read(File.expand_path('../VERSION', __FILE__)).strip

Gem::Specification.new do |spec|
  spec.name          = 'jsonapi-serializable'
  spec.version       = version
  spec.author        = 'Lucas Hosseini'
  spec.email         = 'lucas.hosseini@gmail.com'
  spec.summary       = 'Conveniently serialize JSON API resources.'
  spec.description   = 'Powerful DSL for building resource classes - ' \
                       'efficient and flexible rendering.'
  spec.homepage      = 'https://github.com/jsonapi-rb/jsonapi-serializable'
  spec.license       = 'MIT'

  spec.files         = Dir['README.md', 'lib/**/*']
  spec.require_path  = 'lib'

  spec.add_dependency 'jsonapi-renderer', '~> 0.2.0'

  spec.add_development_dependency 'rake',  '~> 11.3'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'benchmark-ips'
end
