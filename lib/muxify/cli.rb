require 'thor'
require 'muxify/builder'
require 'muxify/linker'

module Muxify
  class CLI < Thor
    desc "add", "Adds tmuxinator config for current (or supplied) path"
    def add(root = Dir.pwd)
      Muxify::Linker.(root: root)
    end

    desc "debug", "Prints tmuxinator config of current (or supplied) path to stdout"
    def debug(root = Dir.pwd)
      puts Muxify::Builder.(root: root)
    end
  end
end
