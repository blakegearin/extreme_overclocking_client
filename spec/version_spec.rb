# frozen_string_literal: true

require 'spec_helper'
require 'extreme_overclocking_client/version'

RSpec.describe ExtremeOverclockingClient do
  describe 'VERSION' do
    it 'has a version number' do
      expect(ExtremeOverclockingClient::VERSION).not_to be nil
    end

    it 'is frozen' do
      expect(ExtremeOverclockingClient::VERSION).to be_frozen
    end
  end
end
