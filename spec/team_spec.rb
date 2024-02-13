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
  let(:response_params) do
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
        'team' => {}
      }
    }
  end
  let(:team_instance) { described_class.new(params) }

  describe '#initialize' do
    let(:params) do
      {
        belongs_to_user:,
        config:,
        id:
      }
    end

    before do
      allow_any_instance_of(described_class).to receive(:fetch).and_return(response_params)
      allow_any_instance_of(described_class).to receive(:build)
    end

    context 'when belongs_to_user is false' do
      let(:belongs_to_user) { false }

      context 'when config is not an instance of ExtremeOverclockingClient::Config' do
        let(:config) { nil }

        it 'raises ArgumentError' do
          expect { team_instance }.to raise_error(
            ArgumentError,
            "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
          )
        end
      end

      context 'when config is valid' do
        context 'when id param is nil' do
          let(:id) { nil }

          it 'raises ArgumentError' do
            expect { team_instance }.to raise_error(ArgumentError, 'Required: id of team')
          end
        end

        context 'when id param is empty' do
          let(:id) { '' }

          it 'raises ArgumentError' do
            expect { team_instance }.to raise_error(ArgumentError, 'Required: id of team')
          end
        end

        context 'when id param is valid' do
          it 'calls fetch and build methods' do
            expect_any_instance_of(described_class).to receive(:fetch).with(config:, id:)
            expect_any_instance_of(described_class).to receive(:build).with(params: response_params)

            team_instance
          end
        end
      end
    end

    context 'when belongs_to_user is true' do
      let(:belongs_to_user) { true }

      it 'calls build method but not fetch method' do
        expect_any_instance_of(described_class).not_to receive(:fetch)
        expect_any_instance_of(described_class).to receive(:build).with(params:)

        team_instance
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
        team_instance.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'does not call fetch and build methods' do
        expect(team_instance).not_to receive(:fetch)
        expect(team_instance).not_to receive(:build)

        team_instance.refresh
      end

      it 'returns nil' do
        expect(team_instance.refresh).to be_nil
      end
    end

    context 'when retrieved_at is older than 3 hours' do
      let(:hours) { 4 }

      before do
        allow(team_instance).to receive(:fetch).and_return(response_params)
        allow(team_instance).to receive(:build)

        team_instance.instance_variable_set(:@id, id)
        team_instance.instance_variable_set(:@config, config)
        team_instance.instance_variable_set(:@retrieved_at, retrieved_at)
      end

      it 'calls fetch and build methods' do
        expect(team_instance).to receive(:fetch).with(config:, id:)
        expect(team_instance).to receive(:build).with(params: response_params)

        team_instance.refresh
      end

      it 'returns self' do
        expect(team_instance.refresh).to eq(team_instance)
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
        allow(team_instance)
          .to receive(:request)
          .with(
            config:,
            endpoint: '/xml/team_summary.php',
            params: { t: id }
          )
          .and_return(response_params)
      end

      it 'calls request method with correct parameters' do
        team_instance.send(:fetch, config:, id:)
      end

      it 'returns params hash' do
        expect(team_instance.send(:fetch, config:, id:)).to eq(response_params['EOC_Folding_Stats']['team'])
      end
    end

    describe '#build' do
      let(:updated_at) { Time.now.to_s }

      before { response_params[:updated_at] = updated_at }

      it 'assigns instance variables' do
        team_instance.send(:build, params: response_params)

        expect(team_instance.id).to eq(response_params['TeamID'])
        expect(team_instance.name).to eq(response_params['Team_Name'])
        expect(team_instance.users[:active]).to eq(response_params['Users_Active'].to_i)
        expect(team_instance.users[:total]).to eq(response_params['Users'].to_i)
        expect(team_instance.rank[:total]).to eq(response_params['Rank'].to_i)
        expect(team_instance.rank[:day_change]).to eq(response_params['Change_Rank_24hr'].to_i)
        expect(team_instance.rank[:week_change]).to eq(response_params['Change_Rank_7days'].to_i)
        expect(team_instance.points[:day_average]).to eq(response_params['Points_24hr_Avg'].to_i)
        expect(team_instance.points[:last_day]).to eq(response_params['Points_Last_24hr'].to_i)
        expect(team_instance.points[:last_week]).to eq(response_params['Points_Last_7days'].to_i)
        expect(team_instance.points[:update]).to eq(response_params['Points_Update'].to_i)
        expect(team_instance.points[:today]).to eq(response_params['Points_Today'].to_i)
        expect(team_instance.points[:week]).to eq(response_params['Points_Week'].to_i)
        expect(team_instance.points[:total]).to eq(response_params['Points'].to_i)
        expect(team_instance.wus).to eq(response_params['WUs'].to_i)
        expect(team_instance.updated_at).to eq(updated_at)
        expect(team_instance.retrieved_at).to eq(Time.now.utc.to_s)
      end
    end
  end
end
