# frozen_string_literal: true

module ExtremeOverclockingClient
  class Team
    include Request

    attr_reader :id,
      :name,
      :users,
      :rank,
      :points,
      :wus,
      :updated_at

    def initialize(params = {})
      unless params[:belongs_to_user]
        config = params[:config] || nil

        unless config.is_a?(ExtremeOverclockingClient::Config)
          raise ArgumentError, "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
        end

        id = params[:id] || nil

        raise ArgumentError, "Required: id of team" unless id

        params = { t: id }
        response = request(
          config: config,
          endpoint: "/xml/team_summary.php",
          params: params,
        )

        raise StandardError, response.body unless response.code == "200"

        stats_hash = Hash.from_xml(response.body)["EOC_Folding_Stats"]
        params = stats_hash["team"]
        params[:updated_at] = Time.at(stats_hash["status"]["Last_Update_Unix_TimeStamp"]&.to_i).utc.to_s
      end

      @id = params["TeamID"]&.to_i
      @name = params["Team_Name"]
      @users = {
        active: params["Users_Active"]&.to_i,
        total: params["Users"]&.to_i,
      }
      @rank = {
        total: params["Rank"]&.to_i,
        day_change: params["Change_Rank_24hr"]&.to_i,
        week_change: params["Change_Rank_7days"]&.to_i,
      }
      @points = {
        day_average: params["Points_24hr_Avg"]&.to_i,
        last_day: params["Points_Last_24hr"]&.to_i,
        last_week: params["Points_Last_7days"]&.to_i,
        update: params["Points_Update"]&.to_i,
        today: params["Points_Today"]&.to_i,
        week: params["Points_Week"]&.to_i,
        total: params["Points"]&.to_i,
      }
      @wus = params["WUs"]&.to_i

      @updated_at = params[:updated_at]
    end

    def self.refresh

    end
  end
end
