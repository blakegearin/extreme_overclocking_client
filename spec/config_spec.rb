# frozen_string_literal: true

require 'spec_helper'
require 'extreme_overclocking_client/config'

RSpec.describe ExtremeOverclockingClient::Config do
  let(:project_url) { 'https://example.com' }
  let(:project_name) { 'Example Project' }
  let(:project_version) { '1.0.0' }
  let(:config) { described_class.new(project_url:, project_name:, project_version:) }

  shared_examples 'an invalid configuration' do |missing_param|
    it "raises ArgumentError when #{missing_param} is missing" do
      expect { config }.to raise_error(ArgumentError, "Param '#{missing_param}' must be defined")
    end
  end

  describe '#initialize' do
    context 'with valid params' do
      it 'initializes with the correct attributes' do
        expect(config.referer).to eq(project_url)
        expect(config.user_agent).to eq(
          "#{project_name}/#{project_version} ExtremeOverclockingClient/" \
          "#{ExtremeOverclockingClient::VERSION} Ruby/#{RUBY_VERSION}"
        )
      end
    end

    context 'with missing param' do
      context 'when project_url' do
        let(:config) { described_class.new(project_url: nil, project_name:, project_version:) }

        include_examples 'an invalid configuration', 'project_url'
      end

      context 'when project_name' do
        let(:config) { described_class.new(project_url:, project_name: nil, project_version:) }

        include_examples 'an invalid configuration', 'project_name'
      end

      context 'when project_version' do
        let(:config) { described_class.new(project_url:, project_name:, project_version: nil) }

        include_examples 'an invalid configuration', 'project_version'
      end
    end

    context 'with empty param' do
      context 'when project_url' do
        let(:config) { described_class.new(project_url: '', project_name:, project_version:) }

        include_examples 'an invalid configuration', 'project_url'
      end

      context 'when project_name' do
        let(:config) { described_class.new(project_url:, project_name: '', project_version:) }

        include_examples 'an invalid configuration', 'project_name'
      end

      context 'when project_version' do
        let(:config) { described_class.new(project_url:, project_name:, project_version: '') }

        include_examples 'an invalid configuration', 'project_version'
      end
    end
  end
end
