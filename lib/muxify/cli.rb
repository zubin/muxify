require 'thor'
require 'muxify/builder'
require 'muxify/linker'

module Muxify
  class CLI < Thor
    desc "add", "Adds tmuxinator config for current path"
    def add
      Muxify::Linker.(root: Dir.pwd)
    end

    desc "debug", "Prints tmuxinator config of current path to stdout"
    def debug
      puts Muxify::Builder.(root: Dir.pwd)
    end
  end
end
