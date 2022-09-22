# frozen_string_literal: true

RSpec.describe Muxify::Builder do
  describe '#to_yaml' do
    subject(:parsed_yaml) { YAML.load(builder.to_yaml) }

    context "without custom config" do
      let(:builder) { described_class.new(fixture_project_path(project_type: 'empty')) }

      it "returns valid YAML" do
        expect { parsed_yaml }.not_to raise_error
      end
    end

    context "with blank custom config" do
      let(:builder) { described_class.new(project_path, custom_config_path: custom_config_path) }
      let(:project_path) { fixture_project_path(project_type: 'empty_with_blank_custom_config') }
      let(:custom_config_path) { File.join(project_path, '.muxifyrc') }

      it "returns valid YAML" do
        expect(File).to exist(custom_config_path), custom_config_path
        expect { parsed_yaml }.not_to raise_error
      end
    end

    context "with custom config (kwarg)" do
      let(:builder) { described_class.new(project_path, custom_config_path: custom_config_path) }
      let(:project_path) { fixture_project_path(project_type: 'with_custom_config') }
      let(:custom_config_path) { File.join(project_path, '.muxifyrc') }

      it "applies kwarg .muxifyrc" do
        expect(File).to exist(custom_config_path), custom_config_path
        expect(parsed_yaml["windows"]).to include("nested_by_project" => "true")
        expect(parsed_yaml["windows"]).to include("not_nested" => "true")
      end
    end

    context "with custom config (no kwarg)" do
      let(:builder) { described_class.new(project_path) }
      let(:project_path) { fixture_project_path(project_type: 'with_custom_config') }

      it "applies project .muxifyrc" do
        expect(parsed_yaml["windows"]).to include("nested_by_project" => "true")
        expect(parsed_yaml["windows"]).to include("not_nested" => "true")
      end
    end
  end

  def fixture_project_path(project_type:)
    File.expand_path(project_type, File.join(__dir__, '../fixtures/example_projects'))
  end
end
