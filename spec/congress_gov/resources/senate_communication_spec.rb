# frozen_string_literal: true

RSpec.describe CongressGov::Resources::SenateCommunication do
  subject(:resource) { CongressGov.senate_communication }

  describe '#list' do
    it 'lists all senate communications' do
      stub_request(:get, %r{api\.congress\.gov/v3/senate-communication\?})
        .to_return(status: 200, body: '{"senateCommunications":[{"number":"456"}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/senate-communication/118\?})
        .to_return(status: 200, body: '{"senateCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 118, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and communication type' do
      stub_request(:get, %r{api\.congress\.gov/v3/senate-communication/118/pm\?})
        .to_return(status: 200, body: '{"senateCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 118, communication_type: 'pm', limit: 1)
      expect(response.results).to eq([])
    end

    it 'raises ArgumentError for invalid communication type' do
      expect { resource.list(congress: 118, communication_type: 'invalid') }
        .to raise_error(ArgumentError, /communication type/)
    end
  end

  describe '#get' do
    it 'fetches a specific senate communication' do
      stub_request(:get, %r{api\.congress\.gov/v3/senate-communication/118/pm/456})
        .to_return(status: 200, body: '{"senateCommunication":{"number":"456","communicationType":{"code":"PM"}}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(118, 'pm', 456)
      expect(response).to be_a(CongressGov::Response)
      expect(response['senateCommunication']).to include('number')
    end

    it 'raises ArgumentError for invalid communication type' do
      expect { resource.get(118, 'invalid', 456) }
        .to raise_error(ArgumentError, /communication type/)
    end
  end
end
