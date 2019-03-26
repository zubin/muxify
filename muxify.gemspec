# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'muxify/version'

Gem::Specification.new do |spec|
  spec.name          = 'muxify'
  spec.version       = Muxify::VERSION
  spec.authors       = ["Zubin Henner"]
  spec.email         = ['zubin@users.noreply.github.com']

  spec.summary       = %q{Simple tmux project config}
  spec.homepage      = 'https://github.com/zubin/muxify'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = ['muxify']
  spec.require_paths = ['lib']

  spec.add_dependency 'thor'
  spec.add_dependency 'tmuxinator'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
