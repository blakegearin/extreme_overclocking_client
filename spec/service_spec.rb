require 'spec_helper'
require 'extreme_overclocking_client/service'

RSpec.describe ExtremeOverclockingClient::Service do
  let(:project_url) { 'https://rspec.test' }
  let(:project_name) { 'RSpec Test' }
  let(:project_version) { '0.0.0' }
  let(:config) do
    ExtremeOverclockingClient::Config.new(
      project_url: project_url,
      project_name: project_name,
      project_version: project_version
    )
  end

  describe '#initialize' do
    it 'sets @config' do
      service = described_class.new(project_url: project_url, project_name: project_name, project_version: project_version)

      expect(service.config.referer).to eq(project_url)
    end
  end

  describe '#team' do
    let(:team_id) { 12345 }
    let(:team_instance) { double('team_instance') }
    let(:config) { ExtremeOverclockingClient::Config.new(project_url: project_url, project_name: project_name, project_version: project_version) }

    subject { described_class.new(project_url: project_url, project_name: project_name, project_version: project_version) }

    before do
      allow(ExtremeOverclockingClient::Team).to receive(:new).and_return(team_instance)
    end

    RSpec::Matchers.define :match_config do |expected_config|
      match do |actual_config|
        actual_config.referer == expected_config.referer &&
          actual_config.user_agent == expected_config.user_agent
      end
    end

    it 'initializes a Team instance with the provided config and team ID' do
      expect(ExtremeOverclockingClient::Team).to receive(:new).with(hash_including(config: match_config(config), id: team_id))

      team = subject.team(id: team_id)

      expect(team).to eq(team_instance)
    end

    context 'when no team ID is provided' do
      it 'raises an ArgumentError' do
        expect { subject.team(id: nil) }.to raise_error(ArgumentError, 'Required: id')
      end
    end
  end
end
