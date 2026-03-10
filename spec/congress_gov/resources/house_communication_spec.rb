# frozen_string_literal: true

RSpec.describe CongressGov::Resources::HouseCommunication do
  subject(:resource) { CongressGov.house_communication }

  describe '#list' do
    it 'lists all house communications' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-communication\?})
        .to_return(status: 200, body: '{"houseCommunications":[{"number":"123"}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-communication/118\?})
        .to_return(status: 200, body: '{"houseCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 118, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and communication type' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-communication/118/ec\?})
        .to_return(status: 200, body: '{"houseCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 118, communication_type: 'ec', limit: 1)
      expect(response.results).to eq([])
    end

    it 'raises ArgumentError for invalid communication type' do
      expect { resource.list(congress: 118, communication_type: 'invalid') }
        .to raise_error(ArgumentError, /communication type/)
    end
  end

  describe '#get' do
    it 'fetches a specific house communication' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-communication/118/ec/1234})
        .to_return(status: 200, body: '{"houseCommunication":{"number":"1234","communicationType":{"code":"EC"}}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(118, 'ec', 1234)
      expect(response).to be_a(CongressGov::Response)
      expect(response['houseCommunication']).to include('number')
    end

    it 'raises ArgumentError for invalid communication type' do
      expect { resource.get(118, 'invalid', 1234) }
        .to raise_error(ArgumentError, /communication type/)
    end
  end
end
