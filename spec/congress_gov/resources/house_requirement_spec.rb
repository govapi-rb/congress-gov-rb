# frozen_string_literal: true

RSpec.describe CongressGov::Resources::HouseRequirement do
  subject(:resource) { CongressGov.house_requirement }

  describe '#list' do
    it 'lists house requirements' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-requirement\?})
        .to_return(status: 200, body: '{"houseRequirements":[{"number":"1"}],"pagination":{"count":10}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'fetches a specific house requirement' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-requirement/8070})
        .to_return(status: 200, body: '{"houseRequirement":{"number":"8070","updateDate":"2025-01-15"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(8070)
      expect(response).to be_a(CongressGov::Response)
      expect(response['houseRequirement']).to include('number')
    end
  end

  describe '#matching_communications' do
    it 'returns matching communications for a requirement' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-requirement/8070/matching-communications})
        .to_return(status: 200,
                   body: '{"matchingCommunications":[{"number":"123"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.matching_communications(8070, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end
end
