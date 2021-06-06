# frozen_string_literal: true

require 'thor'
require 'muxify/builder'
require 'muxify/linker'

module Muxify
  class CLI < Thor
    desc 'add', 'Adds tmuxinator config for current (or supplied) path'
    def add(root = Dir.pwd)
      Muxify::Linker.call(root: root)
    end

    desc 'debug', 'Prints tmuxinator config of current (or supplied) path to stdout'
    def debug(root = Dir.pwd)
      puts Muxify::Builder.call(root)
    end

    desc 'stop', 'Kills tmux session'
    def stop(name = File.basename(Dir.pwd))
      Kernel.system("tmux kill-session -t #{name}")
    end

    desc 'version', 'Print current version'
    def version
      puts Muxify::VERSION
    end
  end
end
