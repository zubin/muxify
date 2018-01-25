require 'yaml'

module Muxify
  class Builder
    def self.call(*args)
      new(*args).to_yaml
    end

    def initialize(root:, name: nil)
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
      Windows.new(root).all
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
          *django,
        ]
      end

      private

      attr_reader :root

      def shell
        [{shell: ('git fetch; git status' if git?)}]
      end

      def git?
        File.exists?(File.join(root, '.git'))
      end

      def editor
        [{editor: ENV.fetch('EDITOR', 'vim')}]
      end

      def logs
        return [] if Dir["#{root}/log/*.log"].empty?
        [{logs: 'tail -f log/*.log'}]
      end

      def foreman
        return [] unless foreman?
        [{foreman: <<-SH.strip}]
          ps aux | grep 'unicorn_rails master' | awk '{print $2}' | xargs kill; foreman start
        SH
      end

      def foreman?
        # TODO?
      end

      def rails
        return [] unless rails?
        [
          {db: 'rails db'},
          {console: 'rails console'},
        ]
      end

      def rails?
        File.exists?(File.join(root, 'bin/rails'))
      end

      def django
        return [] unless django?
        [
          {db: 'python manage.py dbshell'},
          {console: 'python manage.py shell'},
          {server: 'python manage.py runserver'},
        ]
      end

      def django?
        python_requirements = File.join(root, 'requirements.txt')
        File.exists?(python_requirements) && File.read(python_requirements).include?('django')
      end
    end
  end
end
