require 'spec_helper'
require 'extreme_overclocking_client/request'

RSpec.describe ExtremeOverclockingClient::Request do
  let(:dummy_class) { Class.new { extend ExtremeOverclockingClient::Request } }
  let(:dummy_response_body) { '<xml><data>test</data></xml>' }
  let(:feed_url) { 'https://folding.extremeoverclocking.com' }
  let(:endpoint) { '/test_endpoint' }
  let(:url) { feed_url + endpoint }
  let(:config) do
    ExtremeOverclockingClient::Config.new(
      project_url: 'https://rspec.test',
      project_name: 'RSpec Test',
      project_version: '0.0.0'
    )
  end

  before do
    allow(Net::HTTP).to receive(:start).and_return(double('https', request: dummy_response_body))
  end

  describe '#request' do
    context 'when the response code is 200' do
      it 'parses the XML response body' do
        stub_request(:get, url).to_return(body: dummy_response_body, status: 200)

        xml_hash = dummy_class.request(config: config, endpoint: endpoint)

        expect(xml_hash).to eq('xml' => { 'data' => 'test' })
        expect(WebMock).to have_requested(:get, url)
      end
    end

    context 'when the response code is not 200' do
      it 'raises an error with the response body' do
        stub_request(:get, url).to_return(body: 'Error message', status: 500)

        expect {
          dummy_class.request(config: config, endpoint: endpoint)
        }.to raise_error(StandardError, 'Error message')

        expect(WebMock).to have_requested(:get, url)
      end
    end
  end
end
