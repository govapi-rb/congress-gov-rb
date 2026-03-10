# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Amendment do
  subject(:amendment_resource) { CongressGov.amendment }

  describe '#list' do
    it 'lists all amendments' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment\?})
        .to_return(status: 200, body: '{"amendments":[{"number":"1"}],"pagination":{"count":100}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119\?})
        .to_return(status: 200, body: '{"amendments":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.list(congress: 119, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and amendment type' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt\?})
        .to_return(status: 200, body: '{"amendments":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.list(congress: 119, amendment_type: 'samdt', limit: 1)
      expect(response.results).to eq([])
    end
  end

  describe '#get' do
    it 'returns amendment detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt/100\?})
        .to_return(status: 200, body: '{"amendment":{"number":"100","type":"samdt"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.get(119, 'samdt', 100)
      expect(response).to be_a(CongressGov::Response)
      expect(response['amendment']).to include('number', 'type')
    end

    it 'raises ArgumentError for invalid amendment type' do
      expect { amendment_resource.get(119, 'zz', 1) }.to raise_error(ArgumentError, /amendment type/)
    end
  end

  describe '#actions' do
    it 'returns amendment actions' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt/100/actions})
        .to_return(status: 200, body: '{"actions":[{"actionDate":"2025-06-01","text":"Agreed to"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.actions(119, 'samdt', 100)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#amendments' do
    it 'returns sub-amendments' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt/100/amendments})
        .to_return(status: 200, body: '{"amendments":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.amendments(119, 'samdt', 100)
      expect(response.results).to eq([])
    end
  end

  describe '#cosponsors' do
    it 'returns cosponsors' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt/100/cosponsors})
        .to_return(status: 200, body: '{"cosponsors":[{"bioguideId":"B001292"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.cosponsors(119, 'samdt', 100)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#text' do
    it 'returns text versions' do
      stub_request(:get, %r{api\.congress\.gov/v3/amendment/119/samdt/100/text})
        .to_return(status: 200, body: '{"textVersions":[{"type":"Submitted"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = amendment_resource.text(119, 'samdt', 100)
      expect(response.results).to be_an(Array)
    end
  end
end
