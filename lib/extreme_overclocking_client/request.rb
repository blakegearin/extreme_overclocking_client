# frozen_string_literal: false

require "active_support/all"
require "net/http"
require "nokogiri"

ActiveSupport::XmlMini.backend = 'Nokogiri'

module ExtremeOverclockingClient
  module Request
    FEED_URL = "https://folding.extremeoverclocking.com"

    def request(base_url: FEED_URL, config:, endpoint:, params: {})
      unless config.is_a?(ExtremeOverclockingClient::Config)
        raise ArgumentError, "Param 'config' must be an instance of ExtremeOverclockingClient::Config"
      end

      url = URI.join(base_url, endpoint)
      url.query = URI.encode_www_form(params) unless params.empty?

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url.request_uri)
      request['Referer'] = config.referer
      request['User-Agent'] = config.user_agent

      response = http.request(request)

      raise StandardError, response.body unless response.code == "200"

      Hash.from_xml(response.body)
    end
  end
end
