# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Hearing do
  subject(:resource) { CongressGov.hearing }

  describe '#list' do
    it 'lists all hearings' do
      stub_request(:get, %r{api\.congress\.gov/v3/hearing\?})
        .to_return(status: 200, body: '{"hearings":[{"jacketNumber":"12345"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/hearing/119\?})
        .to_return(status: 200, body: '{"hearings":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and chamber' do
      stub_request(:get, %r{api\.congress\.gov/v3/hearing/119/house\?})
        .to_return(status: 200, body: '{"hearings":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, chamber: 'house', limit: 1)
      expect(response.results).to eq([])
    end
  end

  describe '#get' do
    it 'fetches a specific hearing' do
      stub_request(:get, %r{api\.congress\.gov/v3/hearing/119/senate/12345})
        .to_return(status: 200, body: '{"hearing":{"jacketNumber":"12345"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(119, 'senate', 12_345)
      expect(response['hearing']).to include('jacketNumber')
    end
  end
end
