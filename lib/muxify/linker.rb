# frozen_string_literal: true

require "fileutils"

module Muxify
  class Linker
    TMUXINATOR_CONFIG_PATH = File.expand_path(File.join(ENV.fetch("HOME"), ".tmuxinator")).freeze
    private_constant :TMUXINATOR_CONFIG_PATH

    def self.call(**args)
      new(**args).call
    end

    def initialize(root:)
      @root = File.expand_path(root)
    end

    def call
      FileUtils.mkdir_p(TMUXINATOR_CONFIG_PATH)
      File.open(config_path, "w") { |f| f << contents }
    end

    private

    attr_reader :root

    def config_path
      File.join(TMUXINATOR_CONFIG_PATH, "#{name}.yml")
    end

    def name
      File.basename(root)
    end

    def contents
      <<-ERB.strip
        <% require 'muxify' %><%= Muxify::Builder.('#{root}') %>
      ERB
    end
  end
end
