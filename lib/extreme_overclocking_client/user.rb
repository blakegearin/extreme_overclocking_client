# frozen_string_literal: true

module ExtremeOverclockingClient
  class User
    include Request

    attr_reader :id,
      :name,
      :rank,
      :points,
      :wus,
      :team,
      :created_at,
      :updated_at,
      :retrieved_at

    def initialize(
      config:,
      id: nil,
      name: nil,
      team_id: nil
    )
      unless config.is_a?(ExtremeOverclockingClient::Config)
        raise ArgumentError, "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
      end

      params = fetch(config: config, id: id, name: name, team_id: team_id)
      build(params: params)
    end

    def refresh
      time_difference_in_hours = (Time.now.utc - Time.parse(@retrieved_at)) / 3600

      return unless time_difference_in_hours >= 3.0

      params = fetch(config: @config, id: @id)
      build(params: params)

      self
    end

    private

    def fetch(config:, id: nil, name: nil, team_id: nil)
      params = {}

      if id
        params = { u: id }
      elsif name && team_id
        params = {
          t: team_id,
          un: name,
        }
      else
        raise ArgumentError, "Required: id or (name and team_id) of user"
      end

      response = request(
        config: config,
        endpoint: "/xml/user_summary.php",
        params:,
      )

      stats_hash = response["EOC_Folding_Stats"]
      params = stats_hash["user"]
      params[:updated_at] = Time.at(stats_hash["status"]["Last_Update_Unix_TimeStamp"]&.to_i).utc.to_s
      params[:team] = stats_hash["team"]

      params
    end

    def build(params:)
      @id = params["UserID"]&.to_i
      @name = params["User_Name"]
      @rank = {
        team: params["Team_Rank"]&.to_i,
        overall: params["Overall_Rank"]&.to_i,
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

      @created_at = Time.parse(params["First_Record"]).utc.to_s
      @updated_at = params[:updated_at]
      @retrieved_at = Time.now.utc.to_s

      team_hash = params[:team]
      team_hash[:updated_at] = @updated_at
      team_hash[:belongs_to_user] = true

      @team = Team.new(**team_hash)
    end
  end
end
