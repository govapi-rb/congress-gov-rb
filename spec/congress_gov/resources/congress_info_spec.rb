# frozen_string_literal: true

RSpec.describe CongressGov::Resources::CongressInfo do
  subject(:congress_resource) { CongressGov.congress_info }

  describe '#list' do
    it 'lists all congresses' do
      stub_request(:get, %r{api\.congress\.gov/v3/congress\?})
        .to_return(status: 200, body: '{"congresses":[{"number":119,"name":"119th Congress"}],"pagination":{"count":119}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = congress_resource.list(limit: 1)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'returns details for a specific congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/congress/119})
        .to_return(status: 200, body: '{"congress":{"number":119,"name":"119th Congress","startYear":"2025","endYear":"2027"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = congress_resource.get(119)
      expect(response).to be_a(CongressGov::Response)
      expect(response['congress']).to include('number' => 119, 'name' => '119th Congress')
    end
  end

  describe '#current' do
    it 'returns the current congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/congress/current})
        .to_return(status: 200, body: '{"congress":{"number":119,"name":"119th Congress"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = congress_resource.current
      expect(response).to be_a(CongressGov::Response)
      expect(response['congress']).to include('number' => 119)
    end
  end
end
