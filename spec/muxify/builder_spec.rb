# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe Muxify::Builder do
  describe ".call" do
    subject(:call) { described_class.call(project_path) }

    around do |example|
      Dir.mktmpdir do |dir|
        @project_path = dir
        example.run
      end
    end

    let(:project_path) { @project_path }
    let(:parsed_yaml) { YAML.safe_load(call) }

    context "without custom config" do
      it "generates valid YAML" do
        expect { parsed_yaml }.not_to raise_error
      end

      it "has default config" do
        expect(parsed_yaml).to eq(expected_config({}))
      end
    end

    context "with blank custom config" do
      before do
        FileUtils.touch(File.join(project_path, ".muxifyrc"))
      end

      it "has default config" do
        expect(parsed_yaml).to eq(expected_config({}))
      end
    end

    context "with custom config" do
      before do
        File.write(File.join(project_path, ".muxifyrc"), <<~YAML)
          ---
          #{File.basename(project_path)}:
            windows:
              nested_by_project: "true"
          windows:
            not_nested: "true"
        YAML
      end

      it "applies .muxifyrc config" do
        expect(parsed_yaml).to eq(expected_config("nested_by_project" => "true", "not_nested" => "true"))
      end
    end

    context "with a logfile" do
      before do
        Dir.mkdir(File.dirname(logfile))
        File.write(logfile, "some logs")
      end

      let(:logfile) { File.join(project_path, "log/debug.log") }

      it "adds 'logs' window" do
        expect(parsed_yaml).to eq(expected_config("logs" => "tail -f log/*.log"))
      end

      it "truncates logile" do
        expect { call }.to change { File.read(logfile) }.to("")
      end
    end

    context "with a Rails app" do
      before do
        Dir.chdir(project_path) do
          Dir.mkdir("bin")
          FileUtils.touch("bin/rails")
        end
      end

      let(:expected_windows) do
        {
          "db" => "rails db",
          "console" => "rails console",
          "server" => File.join(Muxify.root, "bin/rails_server_with_puma_dev"),
        }
      end

      it "adds expected windows" do
        expect(parsed_yaml).to eq(expected_config(expected_windows))
      end

      context "with a package.json file" do
        before do
          FileUtils.touch(File.join(project_path, "package.json"))
        end

        it "doesn't add NodeJS windows" do
          expect(parsed_yaml).to eq(expected_config(expected_windows))
        end
      end

      context "with custom 'server' config" do
        before do
          File.write(File.join(project_path, ".muxifyrc"), <<~YAML)
            ---
            windows:
              server: "foreman start"
          YAML
        end

        let(:expected_windows) do
          {
            "db" => "rails db",
            "console" => "rails console",
            "server" => "foreman start",
          }
        end

        it "overrides default" do
          expect(parsed_yaml).to eq(expected_config(expected_windows))
        end
      end
    end

    context "with a non-Phoenix Elixir app" do
      before do
        FileUtils.touch(File.join(project_path, "mix.exs"))
      end

      let(:expected_windows) do
        {
          "console" => "iex -S mix",
          "server" => "mix",
        }
      end

      it "adds expected windows" do
        expect(parsed_yaml).to eq(expected_config(expected_windows))
      end
    end

    context "with a Phoenix Elixir app" do
      before do
        FileUtils.mkdir_p(File.join(project_path, "deps/phoenix"))
      end

      let(:expected_windows) do
        {
          "console" => "iex -S mix phx.server",
          "server" => "mix phx.server",
        }
      end

      it "adds expected windows" do
        expect(parsed_yaml).to eq(expected_config(expected_windows))
      end
    end

    context "with a JS app" do
      before do
        FileUtils.touch(File.join(project_path, "package.json"))
      end

      let(:expected_windows) do
        {
          "console" => "node",
        }
      end

      it "adds expected windows" do
        expect(parsed_yaml).to eq(expected_config(expected_windows))
      end
    end

    context "with a Django app" do
      before do
        File.write(File.join(project_path, "requirements.txt"), "django")
      end

      let(:expected_windows) do
        {
          "db" => "python manage.py dbshell",
          "console" => "python manage.py shell",
          "server" => "python manage.py runserver",
        }
      end

      it "adds expected windows" do
        expect(parsed_yaml).to eq(expected_config(expected_windows))
      end
    end

    def expected_config(extra_windows)
      {
        "name" => File.basename(project_path),
        "root" => project_path,
        "windows" => [
          {"shell" => "echo \"Not a git repository.\""},
          {"editor" => ENV["EDITOR"] || "vim"},
        ] + extra_windows.each_with_object([]) { |(k, v), result| result << {k => v} },
      }
    end
  end
end
