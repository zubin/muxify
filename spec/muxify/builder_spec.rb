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
        File.open(File.join(project_path, ".muxifyrc"), "w") do |file|
          file << <<~YAML
            ---
            #{File.basename(project_path)}:
              windows:
                nested_by_project: "true"
            windows:
              not_nested: "true"
          YAML
        end
      end

      it "applies .muxifyrc config" do
        expect(parsed_yaml).to eq(expected_config("nested_by_project" => "true", "not_nested" => "true"))
      end
    end

    context "with a logfile" do
      before do
        Dir.mkdir(File.dirname(logfile))
        File.open(logfile, "w") { |file| file << "some logs" }
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

    def expected_config(extra_windows)
      {
        "name" => File.basename(project_path),
        "root" => project_path,
        "windows" => [
          {"shell" => "git fetch; git status"},
          {"editor" => ENV["EDITOR"] || "vim"},
        ] + extra_windows.each_with_object([]) { |(k, v), result| result << {k => v} },
      }
    end
  end
end
