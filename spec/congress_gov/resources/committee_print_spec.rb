# frozen_string_literal: true

RSpec.describe CongressGov::Resources::CommitteePrint do
  subject(:resource) { CongressGov.committee_print }

  describe '#list' do
    it 'lists all committee prints' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-print\?})
        .to_return(status: 200, body: '{"committeePrints":[{"jacketNumber":"12345"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-print/119\?})
        .to_return(status: 200, body: '{"committeePrints":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and chamber' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-print/119/house\?})
        .to_return(status: 200, body: '{"committeePrints":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, chamber: 'house', limit: 1)
      expect(response.results).to eq([])
    end
  end

  describe '#get' do
    it 'fetches a specific committee print' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-print/119/senate/12345})
        .to_return(status: 200, body: '{"committeePrint":{"jacketNumber":"12345"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(119, 'senate', 12_345)
      expect(response['committeePrint']).to include('jacketNumber')
    end
  end

  describe '#text' do
    it 'returns text versions of a committee print' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-print/119/house/12345/text})
        .to_return(status: 200, body: '{"textVersions":[{"type":"Printed"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.text(119, 'house', 12_345)
      expect(response.results).to be_an(Array)
    end
  end
end
