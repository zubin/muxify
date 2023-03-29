# frozen_string_literal: true

RSpec.describe Muxify::Builder do
  describe ".call" do
    subject(:call) { described_class.call(project_path, **kwargs) }

    let(:kwargs) { {} }
    let(:parsed_yaml) { YAML.safe_load(call) }

    context "without custom config" do
      let(:project_path) { fixture_project_path(project_type: "empty") }

      it "generates valid YAML" do
        expect { parsed_yaml }.not_to raise_error
      end

      it "has default config" do
        expect(parsed_yaml).to eq(expected_config({}))
      end
    end

    context "with blank custom config" do
      let(:project_path) { fixture_project_path(project_type: "empty_with_blank_custom_config") }
      let(:kwargs) { {custom_config_path: File.join(project_path, ".muxifyrc")}  }

      it "has default config" do
        expect(parsed_yaml).to eq(expected_config({}))
      end
    end

    context "with custom config (kwarg)" do
      let(:project_path) { fixture_project_path(project_type: "with_custom_config") }
      let(:kwargs) { {custom_config_path: File.join(project_path, ".muxifyrc")}  }

      it "applies kwarg .muxifyrc" do
        expect(parsed_yaml).to eq(expected_config("nested_by_project" => "true", "not_nested" => "true"))
      end
    end

    def fixture_project_path(project_type:)
      File.expand_path(project_type, File.join(__dir__, "../fixtures/example_projects"))
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
