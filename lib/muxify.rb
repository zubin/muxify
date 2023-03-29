# frozen_string_literal: true

require "muxify/cli"
require "muxify/version"

module Muxify
  def self.root
    File.expand_path("..", __dir__)
  end
end
