# frozen_string_literal: true

module ExtremeOverclockingClient
  class Config
    attr_reader :referer, :user_agent

    def initialize(project_url:, project_name:, project_version:)
      raise ArgumentError, "Param 'project_url' must be defined" unless project_url && !project_url.empty?

      raise ArgumentError, "Param 'project_name' must be defined" unless project_name && !project_name.empty?

      raise ArgumentError, "Param 'project_version' must be defined" unless project_version && !project_version.empty?

      @referer = project_url
      @user_agent = "#{project_name}/#{project_version} ExtremeOverclockingClient/" \
                    "#{ExtremeOverclockingClient::VERSION} Ruby/#{RUBY_VERSION}"
    end
  end
end
