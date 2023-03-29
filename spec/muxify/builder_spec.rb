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
