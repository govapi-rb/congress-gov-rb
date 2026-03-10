# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Committee do
  subject(:committee_resource) { CongressGov.committee }

  describe '#list' do
    it 'lists all committees' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee\?})
        .to_return(status: 200, body: '{"committees":[{"name":"Appropriations"}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by chamber' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/house\?})
        .to_return(status: 200, body: '{"committees":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.list(chamber: 'house', limit: 1)
      expect(response.results).to eq([])
    end

    it 'raises ArgumentError for invalid chamber' do
      expect { committee_resource.list(chamber: 'invalid') }.to raise_error(ArgumentError, /chamber/)
    end

    it 'filters by congress only' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/119\?})
        .to_return(status: 200, body: '{"committees":[{"name":"Appropriations"}],"pagination":{"count":30}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.list(congress: 119, limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress and chamber' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/119/senate\?})
        .to_return(status: 200, body: '{"committees":[{"name":"Appropriations"}],"pagination":{"count":20}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.list(congress: 119, chamber: 'senate', limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'fetches committee detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/senate/ssap00})
        .to_return(status: 200, body: '{"committee":{"name":"Appropriations"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.get('senate', 'ssap00')
      expect(response['committee']).to include('name')
    end
  end

  describe '#bills' do
    it 'returns bills referred to a committee' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/house/hsap00/bills})
        .to_return(status: 200, body: '{"bills":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.bills('house', 'hsap00', limit: 1)
      expect(response.results).to eq([])
    end
  end

  describe '#get_by_congress' do
    it 'fetches committee detail scoped to a congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/119/senate/ssap00})
        .to_return(status: 200, body: '{"committee":{"name":"Appropriations"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.get_by_congress(119, 'senate', 'ssap00')
      expect(response['committee']).to include('name')
    end
  end

  describe '#reports' do
    it 'returns reports for a committee' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/senate/ssap00/reports})
        .to_return(status: 200, body: '{"reports":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.reports('senate', 'ssap00', limit: 5)
      expect(response.results).to eq([])
    end
  end

  describe '#nominations' do
    it 'returns nominations for a committee' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/senate/ssju00/nominations})
        .to_return(status: 200, body: '{"nominations":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.nominations('senate', 'ssju00', limit: 5)
      expect(response.results).to eq([])
    end
  end

  describe '#house_communication' do
    it 'returns house communications for a committee' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/house/hsap00/house-communication})
        .to_return(status: 200, body: '{"houseCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.house_communication('house', 'hsap00', limit: 5)
      expect(response.results).to eq([])
    end
  end

  describe '#senate_communication' do
    it 'returns senate communications for a committee' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee/senate/ssap00/senate-communication})
        .to_return(status: 200, body: '{"senateCommunications":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.senate_communication('senate', 'ssap00', limit: 5)
      expect(response.results).to eq([])
    end
  end

  describe '#for_member' do
    it 'returns committees for a member' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-membership/B001292})
        .to_return(status: 200, body: '{"committees":[{"name":"Ways and Means"}],"pagination":{"count":2}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = committee_resource.for_member('B001292')
      expect(response.results).to be_an(Array)
    end
  end
end
