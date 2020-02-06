# frozen_string_literal: true

require 'yaml'

module Muxify
  class Builder
    CUSTOM_CONFIG_PATH = File.join(ENV['HOME'], '.muxifyrc')
    private_constant :CUSTOM_CONFIG_PATH

    def self.call(*args)
      new(*args).to_yaml
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
        'name' => name,
        'root' => root,
        'windows' => windows,
      }
    end

    def windows
      Windows.new(root).all.tap do |windows|
        custom_windows.each do |name, command|
          windows << {name => command}
        end
      end
    end

    def custom_windows
      return {} unless File.exist?(CUSTOM_CONFIG_PATH)

      YAML.load_file(CUSTOM_CONFIG_PATH).dig(name, 'windows') || {}
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
          *foreman,
          *rails,
          *elixir_non_phoenix,
          *phoenix,
          *nodejs,
          *django,
        ]
      end

      private

      attr_reader :root

      def shell
        [{'shell' => init_shell}]
      end

      def init_shell
        if git?
          'git fetch; git status'
        else
          'echo "Not a git repository."'
        end
      end

      def git?
        directory?('.git')
      end

      def editor
        [{'editor' => ENV.fetch('EDITOR', 'vim')}]
      end

      def logs
        return [] if logfiles.empty?

        logfiles.each(&method(:truncate_file))
        [{'logs' => 'tail -f log/*.log'}]
      end

      def logfiles
        @logfiles ||= Dir["#{root}/log/*.log"]
      end

      def truncate_file(path)
        File.truncate(path, 0)
      end

      def foreman
        return [] unless foreman?

        [{'foreman' => <<-SH.strip}]
        ps aux | grep 'unicorn_rails master' | awk '{print $2}' | xargs kill; foreman start
        SH
      end

      def foreman?
        # TODO?
      end

      def rails
        return [] unless rails?

        [
          {'db' => 'rails db'},
          {'console' => 'rails console'},
        ]
      end

      def rails?
        exists?('bin/rails')
      end

      def elixir_non_phoenix
        return [] unless elixir_non_phoenix?

        [
          {'console' => 'iex -S mix'},
          {'server' => 'mix'},
        ]
      end

      def elixir_non_phoenix?
        exists?('mix.exs') && !phoenix?
      end

      def phoenix
        return [] unless phoenix?

        [
          {'console' => 'iex -S mix phoenix.server'},
          {'server' => 'mix phoenix.server'},
        ]
      end

      def phoenix?
        directory?('deps/phoenix')
      end

      def nodejs
        return [] unless nodejs?

        [
          {'console' => 'node'},
        ]
      end

      def nodejs?
        exists?('package.json') && !rails?
      end

      def django
        return [] unless django?

        [
          {'db' => 'python manage.py dbshell'},
          {'console' => 'python manage.py shell'},
          {'server' => 'python manage.py runserver'},
        ]
      end

      def django?
        python_requirements = File.join(root, 'requirements.txt')
        File.exist?(python_requirements) && File.read(python_requirements).include?('django')
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
