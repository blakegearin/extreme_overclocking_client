# frozen_string_literal: true

require 'spec_helper'
require 'extreme_overclocking_client/team'

RSpec.describe ExtremeOverclockingClient::Team do
  let(:config) do
    ExtremeOverclockingClient::Config.new(
      project_url: 'https://rspec.test',
      project_name: 'RSpec Test',
      project_version: '0.0.0'
    )
  end
  let(:id) { 123 }
  let(:response) do
    {
      'TeamID' => 123,
      'Team_Name' => 'Team Name',
      'Users_Active' => 10,
      'Users' => 20,
      'Rank' => 5,
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
      'EOC_Folding_Stats' => {
        'status' => {
          'Last_Update_Unix_TimeStamp' => Time.now.to_i
        },
        'team' => {},
      }
    }
  end
  let(:team) { described_class.new(params) }

  describe '#initialize' do
    let(:params) do
      {
        belongs_to_user:,
        config:,
        id:
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:fetch).and_return(response)
      allow_any_instance_of(described_class).to receive(:build)
    end

    context 'when belongs_to_user is false' do
      let(:belongs_to_user) { false }

      context 'when config is not an instance of ExtremeOverclockingClient::Config' do
        let(:config) { nil }

        it 'raises ArgumentError' do
          expect { team }.to raise_error(
            ArgumentError,
            "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
          )
        end
      end

      context 'when config is valid' do
        context 'when id param is nil' do
          let(:id) { nil }

          it 'raises ArgumentError' do
            expect { team }.to raise_error(ArgumentError, 'Required: id of team')
          end
        end

        context 'when id param is empty' do
          let(:id) { '' }

          it 'raises ArgumentError' do
            expect { team }.to raise_error(ArgumentError, 'Required: id of team')
          end
        end

        context 'when id param is valid' do
          it 'calls fetch and build methods' do
            expect_any_instance_of(described_class).to receive(:fetch).with(config:, id:)
            expect_any_instance_of(described_class).to receive(:build).with(params: response)

            team
          end
        end
      end
    end

    context 'when belongs_to_user is true' do
      let(:belongs_to_user) { true }

      it 'calls build method but not fetch method' do
        expect_any_instance_of(described_class).not_to receive(:fetch)
        expect_any_instance_of(described_class).to receive(:build).with(params:)

        team
      end
    end
  end

  describe '#refresh' do
    let(:params) do
      {
        belongs_to_user: true,
        config:
      }
    end
    let(:retrieved_at) { (Time.now - (hours * 60 * 60)).to_s }

    context 'when retrieved_at is not older than 3 hours' do
      let(:hours) { 2 }

      before do
        team.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'does not call fetch and build methods' do
        expect(team).not_to receive(:fetch)
        expect(team).not_to receive(:build)

        team.refresh
      end

      it 'returns nil' do
        expect(team.refresh).to be_nil
      end
    end

    context 'when retrieved_at is older than 3 hours' do
      let(:hours) { 4 }

      before do
        allow(team).to receive(:fetch).and_return(response)
        allow(team).to receive(:build)

        team.instance_variable_set(:@id, id)
        team.instance_variable_set(:@config, config)
        team.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'calls fetch and build methods' do
        expect(team).to receive(:fetch).with(config:, id:)
        expect(team).to receive(:build).with(params: response)

        team.refresh
      end

      it 'returns self' do
        expect(team.refresh).to eq(team)
      end
    end
  end

  describe 'private methods' do
    let(:params) do
      {
        belongs_to_user: true,
        config:
      }
    end

    describe '#fetch' do
      before do
        allow_any_instance_of(ExtremeOverclockingClient::Request).to receive(:request).and_return(response)
      end

      it 'calls request method with correct parameters' do
        expect_any_instance_of(ExtremeOverclockingClient::Request).to receive(:request).once
        team.send(:fetch, config:, id:)
      end

      it 'returns params hash' do
        expect(team.send(:fetch, config:, id:)).to eq(response['EOC_Folding_Stats']['team'])
      end
    end

    describe '#build' do
      let(:updated_at) { Time.now.to_s }

      before { response[:updated_at] = updated_at }

      it 'assigns instance variables' do
        team.send(:build, params: response)

        expect(team.id).to eq(response['TeamID'])
        expect(team.name).to eq(response['Team_Name'])
        expect(team.users[:active]).to eq(response['Users_Active'].to_i)
        expect(team.users[:total]).to eq(response['Users'].to_i)
        expect(team.rank[:total]).to eq(response['Rank'].to_i)
        expect(team.rank[:day_change]).to eq(response['Change_Rank_24hr'].to_i)
        expect(team.rank[:week_change]).to eq(response['Change_Rank_7days'].to_i)
        expect(team.points[:day_average]).to eq(response['Points_24hr_Avg'].to_i)
        expect(team.points[:last_day]).to eq(response['Points_Last_24hr'].to_i)
        expect(team.points[:last_week]).to eq(response['Points_Last_7days'].to_i)
        expect(team.points[:update]).to eq(response['Points_Update'].to_i)
        expect(team.points[:today]).to eq(response['Points_Today'].to_i)
        expect(team.points[:week]).to eq(response['Points_Week'].to_i)
        expect(team.points[:total]).to eq(response['Points'].to_i)
        expect(team.wus).to eq(response['WUs'].to_i)
        expect(team.updated_at).to eq(updated_at)
        expect(team.retrieved_at).to eq(Time.now.utc.to_s)
      end
    end
  end
end
