# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-vis'
  gem.version       = '0.1.5'
  # gem.license       = 'MIT'
  gem.summary       = 'Helper to connect to Vipassana Identity Server'
  gem.description   = 'This allows you to connect to Vipassana identity server with your ruby app'
  gem.authors       = ['Dhamma workers']
  gem.email         = ['sebastian.castro@dhamma.org', 'ryan.johnson@dhamma.org']
  gem.homepage      = 'https://github.com/dhammaorg/omniauth-vis'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'omniauth-oauth2', '~> 1.2'
end
