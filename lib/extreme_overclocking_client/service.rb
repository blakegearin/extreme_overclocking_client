# frozen_string_literal: true

module ExtremeOverclockingClient
  class Service
    attr_reader :config

    def initialize(project_url:, project_name:, project_version:)
      @config = Config.new(
        project_url: project_url,
        project_name: project_name,
        project_version: project_version,
      )
    end

    def team(id:)
      raise ArgumentError, "Required: id" unless id

      Team.new(config: @config, id: id)
    end

    def teams(ids:)
      raise ArgumentError, "Required: ids" unless ids

      ids.map do |id|
        rate_limit

        if id.is_a?(Integer)
          begin
            Team.new(config: @config, id: id)
          rescue => error
            { id: id, error: error }
          end
        else
          { error: "Ids entry is not an integer: #{id}" }
        end
      end
    end

    def user(id:, name: nil, team_id: nil)
      if id
        User.new(config: @config, id: id)
      elsif name && team_id
        User.new(config: @config, name: name, team_id: team_id)
      else
        raise ArgumentError, "Required: id or (name and team_id) of user"
      end
    end

    def users(ids: nil, hashes: nil)
      if ids
        ids.map do |item|
          begin
            rate_limit

            id = nil

            if item.is_a?(Integer)
              id = item
            else
              symbol_hash = item.transform_keys(&:to_sym) if item.is_a?(Hash)
              id = symbol_hash[:id] if symbol_hash
            end

            if id
              User.new(config: @config, id: id)
            else
              { error: "Could not find id: #{item}" }
            end
          rescue => error
            { id: id, error: error }
          end
        end
      elsif hashes
        hashes.map do |hash|
          begin
            rate_limit

            if hash.is_a?(Hash)
              symbol_hash = hash.transform_keys(&:to_sym)
              User.new(
                config: @config,
                name: symbol_hash[:name],
                team_id: symbol_hash[:team_id],
              )
            else
              { error: "Hashes entry is not a hash: #{hash}" }
            end
          rescue => error
            { id: id, error: error }
          end
        end
      else
        raise ArgumentError, "Required: ids or hashes"
      end
    end

    private

    def rate_limit
      # Limit to 2 calls per second
      sleep(0.5)
    end
  end
end
