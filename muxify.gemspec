# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "muxify/version"

Gem::Specification.new do |spec|
  spec.name = "muxify"
  spec.version = Muxify::VERSION
  spec.authors = ["Zubin Henner"]
  spec.email = ["zubin@users.noreply.github.com"]

  spec.summary = "Simple tmux project config"
  spec.homepage = "https://github.com/zubin/muxify"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir = "bin"
  spec.executables = ["muxify"]
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 3.0.0"

  spec.add_dependency "thor"
  spec.add_dependency "tmuxinator"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
