# frozen_string_literal: true

RSpec.describe Muxify::Builder do
  describe '#to_yaml' do
    subject(:to_yaml) { builder.to_yaml }

    context "without custom config" do
      let(:builder) { described_class.new(fixture_project_path(project_type: 'empty')) }

      it "returns valid YAML" do
        expect { YAML.parse(to_yaml) }.not_to raise_error
      end
    end
  end

  def fixture_project_path(project_type:)
    File.expand_path(project_type, File.join(__dir__, '../fixtures/example_projects'))
  end
end
