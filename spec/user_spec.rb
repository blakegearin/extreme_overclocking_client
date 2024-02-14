# frozen_string_literal: true

require 'spec_helper'
require 'extreme_overclocking_client/user'

RSpec.describe ExtremeOverclockingClient::User do
  let(:config) do
    ExtremeOverclockingClient::Config.new(
      project_url: 'https://rspec.test',
      project_name: 'RSpec Test',
      project_version: '0.0.0'
    )
  end
  let(:id) { 123 }
  let(:name) { nil }
  let(:response) do
    {
      'UserID' => 123,
      'User_Name' => 'Team Name',
      'Team_Rank' => 10,
      'Overall_Rank' => 20,
      'Change_Rank_24hr' => 1,
      'Change_Rank_7days' => -2,
      'Points_24hr_Avg' => 100,
      'Points_Last_24hr' => 200,
      'Points_Last_7days' => 1500,
      'Points_Update' => 300,
      'Points_Today' => 50,
      'Points_Week' => 500,
      'Points' => 1000,
      'WUs' => 5000,
      'First_Record' => Time.now.utc.to_s,
      'EOC_Folding_Stats' => {
        'status' => {
          'Last_Update_Unix_TimeStamp' => Time.now.to_i
        },
        'user' => {},
        'team' => nil,
      },
    }
  end
  let(:team_id) { 456 }
  let(:user) do
    described_class.new(
      config:,
      id:,
      name:,
      team_id:,
    )
  end

  describe '#initialize' do
    before do
      allow_any_instance_of(described_class).to receive(:fetch).and_return(response)
      allow_any_instance_of(described_class).to receive(:build)
    end

    context 'when config is not an instance of ExtremeOverclockingClient::Config' do
      let(:config) { nil }

      it 'raises ArgumentError' do
        expect { user }.to raise_error(
          ArgumentError,
          "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
        )
      end
    end

    context 'when config is valid' do
      it 'calls fetch and build methods' do
        expect_any_instance_of(described_class).to receive(:fetch).with(config:, id:, name:, team_id:)
        expect_any_instance_of(described_class).to receive(:build).with(params: response)

        user
      end
    end
  end

  describe '#refresh' do
    let(:retrieved_at) { (Time.now - (hours * 60 * 60)).to_s }

    before do
      allow_any_instance_of(described_class).to receive(:fetch).and_return(response)
      allow_any_instance_of(described_class).to receive(:build)
    end

    context 'when retrieved_at is not older than 3 hours' do
      let(:hours) { 2 }

      before do
        user.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'does not call fetch and build methods' do
        expect(user).not_to receive(:fetch)
        expect(user).not_to receive(:build)

        user.refresh
      end

      it 'returns nil' do
        expect(user.refresh).to be_nil
      end
    end

    context 'when retrieved_at is older than 3 hours' do
      let(:hours) { 4 }

      before do
        allow(user).to receive(:fetch).and_return(response)
        allow(user).to receive(:build)

        user.instance_variable_set(:@id, id)
        user.instance_variable_set(:@config, config)
        user.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'calls fetch and build methods' do
        expect(user).to receive(:fetch).with(config:, id:)
        expect(user).to receive(:build).with(params: response)

        user.refresh
      end

      it 'returns self' do
        expect(user.refresh).to eq(user)
      end
    end
  end

  describe 'private methods' do
    describe '#fetch' do
      before do
        allow_any_instance_of(ExtremeOverclockingClient::Request).to receive(:request).and_return(response)
        allow_any_instance_of(described_class).to receive(:build)
      end

      context 'when name and team_id are present' do
        let(:name) { 'User Name' }
        let(:team_id) { 456 }

        it 'calls request method with correct parameters' do
          # Twice because initialize calls fetch
          expect_any_instance_of(ExtremeOverclockingClient::Request).to receive(:request).twice
          user.send(:fetch, config:, name:, team_id:)
        end
      end

      it 'returns params hash' do
        expect(user.send(:fetch, config:, id:)).to eq({
          team: nil,
          updated_at: Time.now.utc.to_s,
        })
      end
    end

    describe '#build' do
      let(:updated_at) { Time.now.to_s }

      before do
        response[:team] = { updated_at: }
        response[:updated_at] = updated_at

        allow_any_instance_of(described_class).to receive(:fetch).and_return(response)
      end

      it 'assigns instance variables' do
        user.send(:build, params: response)

        expect(user.id).to eq(response['UserID'])
        expect(user.name).to eq(response['User_Name'])
        expect(user.rank[:team]).to eq(response['Team_Rank'].to_i)
        expect(user.rank[:overall]).to eq(response['Overall_Rank'].to_i)
        expect(user.rank[:day_change]).to eq(response['Change_Rank_24hr'].to_i)
        expect(user.rank[:week_change]).to eq(response['Change_Rank_7days'].to_i)
        expect(user.points[:day_average]).to eq(response['Points_24hr_Avg'].to_i)
        expect(user.points[:last_day]).to eq(response['Points_Last_24hr'].to_i)
        expect(user.points[:last_week]).to eq(response['Points_Last_7days'].to_i)
        expect(user.points[:update]).to eq(response['Points_Update'].to_i)
        expect(user.points[:today]).to eq(response['Points_Today'].to_i)
        expect(user.points[:week]).to eq(response['Points_Week'].to_i)
        expect(user.points[:total]).to eq(response['Points'].to_i)
        expect(user.wus).to eq(response['WUs'].to_i)
        expect(user.updated_at).to eq(updated_at)
        expect(user.retrieved_at).to eq(Time.now.utc.to_s)
      end
    end
  end
end
