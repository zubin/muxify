# frozen_string_literal: true

require "yaml"

module Muxify
  class Builder
    def self.call(path, **kwargs)
      new(path, **kwargs).to_yaml
    end

    def initialize(root, name: nil)
      @root = File.expand_path(root)
      @name = name || File.basename(@root)
    end

    def to_yaml
      config.to_yaml
    end

    private

    attr_reader :root, :name

    def config
      {
        "name" => name,
        "root" => root,
        "windows" => windows
      }
    end

    def windows
      windows = Windows.new(root).all.tap do |windows|
        custom_windows.each do |name, command|
          windows << {name => command}
        end
      end

      windows
        .each_with_object({}) { |window, result| result[window.keys.first] = window.values.first }
        .each_with_object([]) { |(k, v), result| result << {k => v} }
    end

    def custom_windows
      custom_config_paths.each_with_object({}) do |custom_config_path, result|
        [
          YAML.safe_load_file(custom_config_path)&.dig("windows")
        ].compact.each(&result.method(:merge!))
      end
    end

    def custom_config_paths
      [
        project_custom_config_path,
      ].compact.uniq.select(&File.method(:exist?))
    end

    def project_custom_config_path
      File.join(root, ".muxify.yml")
    end

    class Windows
      def initialize(root)
        @root = root
      end

      def all
        [
          *shell,
          *editor,
          *logs,
          *rails,
          *elixir_non_phoenix,
          *phoenix,
          *nodejs,
          *django
        ]
      end

      private

      attr_reader :root

      def shell
        [{"shell" => init_shell}]
      end

      def init_shell
        return 'echo "Not a git repository."' unless git?

        "git fetch; git status"
      end

      def git?
        system("cd #{root} && git rev-parse &>/dev/null")
      end

      def editor
        [{"editor" => ENV.fetch("EDITOR", "vim")}]
      end

      def logs
        return [] if logfiles.empty?

        logfiles.each(&method(:truncate_file))
        [{"logs" => "tail -f log/*.log"}]
      end

      def logfiles
        @logfiles ||= Dir["#{root}/log/*.log"]
      end

      def truncate_file(path)
        File.truncate(path, 0)
      end

      def rails
        return [] unless rails?

        [
          {"db" => "rails db"},
          {"console" => "rails console"},
          {"server" => File.join(Muxify.root, "bin/rails_server_with_puma_dev")},
        ]
      end

      def rails?
        exists?("bin/rails")
      end

      def elixir_non_phoenix
        return [] unless elixir_non_phoenix?

        [
          {"console" => "iex -S mix"},
          {"server" => "mix"}
        ]
      end

      def elixir_non_phoenix?
        exists?("mix.exs") && !phoenix?
      end

      def phoenix
        return [] unless phoenix?

        [
          {"console" => "iex -S mix phx.server"},
          {"server" => "mix phx.server"}
        ]
      end

      def phoenix?
        directory?("deps/phoenix")
      end

      def nodejs
        return [] unless nodejs?

        [
          {"console" => "node"}
        ]
      end

      def nodejs?
        exists?("package.json") && !rails?
      end

      def django
        return [] unless django?

        [
          {"db" => "python manage.py dbshell"},
          {"console" => "python manage.py shell"},
          {"server" => "python manage.py runserver"}
        ]
      end

      def django?
        python_requirements = File.join(root, "requirements.txt")
        File.exist?(python_requirements) && File.read(python_requirements).include?("django")
      end

      def directory?(relative_path)
        File.directory?(File.join(root, relative_path))
      end

      def exists?(relative_path)
        File.exist?(File.join(root, relative_path))
      end
    end
  end
end
