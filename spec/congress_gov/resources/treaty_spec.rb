# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Treaty do
  subject(:treaty_resource) { described_class.new }

  describe '#list' do
    it 'lists all treaties' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty\?})
        .to_return(status: 200, body: '{"treaties":[{"congress":119}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.list(limit: 1)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119\?})
        .to_return(status: 200, body: '{"treaties":[{"congress":119}],"pagination":{"count":10}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.list(congress: 119, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'returns treaty detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119/5})
        .to_return(status: 200, body: '{"treaty":{"congress":119,"number":"5","topic":"Tax Convention"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.get(119, 5)
      expect(response).to be_a(CongressGov::Response)
      expect(response['treaty']).to include('congress', 'number')
    end
  end

  describe '#get_with_suffix' do
    it 'returns treaty detail with suffix' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119/5/A})
        .to_return(status: 200, body: '{"treaty":{"congress":119,"number":"5","suffix":"A"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.get_with_suffix(119, 5, 'A')
      expect(response).to be_a(CongressGov::Response)
      expect(response['treaty']).to include('suffix')
    end
  end

  describe '#actions' do
    it 'returns treaty actions' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119/5/actions})
        .to_return(status: 200, body: '{"actions":[{"actionDate":"2025-06-01","text":"Ratified"}],"pagination":{"count":3}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.actions(119, 5)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#actions_with_suffix' do
    it 'returns actions for a treaty with suffix' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119/5/A/actions})
        .to_return(status: 200, body: '{"actions":[{"actionDate":"2025-06-15","text":"Committee discharged"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.actions_with_suffix(119, 5, 'A')
      expect(response.results).to be_an(Array)
    end
  end

  describe '#committees' do
    it 'returns treaty committees' do
      stub_request(:get, %r{api\.congress\.gov/v3/treaty/119/5/committees})
        .to_return(status: 200, body: '{"committees":[{"name":"Foreign Relations"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = treaty_resource.committees(119, 5)
      expect(response.results).to be_an(Array)
    end
  end
end
