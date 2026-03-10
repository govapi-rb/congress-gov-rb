# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Member do
  subject(:member_resource) { CongressGov.member }

  let(:client) { CongressGov.client }

  describe '#by_district' do
    it 'requests the correct path with zero-padded district' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119/VA/08})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292","state":"Virginia","partyName":"Democratic","n":"Beyer, Donald S."}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_district(state: 'VA', district: 8, congress: 119)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).not_to be_empty
      rep = response.results.first
      expect(rep).to include('bioguideId', 'partyName', 'state', 'n')
      expect(rep['state']).to eq('Virginia')
    end

    it 'zero-pads single-digit district numbers' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119/VA/08})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_district(state: 'VA', district: '8', congress: 119)
      expect(response.results).not_to be_empty
    end

    it 'upcases the state abbreviation' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119/OH/13})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"S001223"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_district(state: 'oh', district: 13, congress: 119)
      expect(response.results.first['bioguideId']).to eq('S001223')
    end
  end

  describe '#get' do
    it 'fetches a member profile by bioguide ID' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/B001292})
        .to_return(status: 200, body: '{"member":{"bioguideId":"B001292","directOrderName":"Donald S. Beyer"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.get('B001292')
      expect(response['member']).to include('bioguideId' => 'B001292')
    end

    it 'raises NotFoundError for unknown bioguide ID' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/Z999999})
        .to_return(status: 404, body: '{"error":"not found"}',
                   headers: { 'Content-Type' => 'application/json' })

      expect { member_resource.get('Z999999') }.to raise_error(CongressGov::NotFoundError)
    end
  end

  describe '#sponsored_legislation' do
    it 'returns bills sponsored by the member' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/S001223/sponsored-legislation})
        .to_return(status: 200, body: '{"sponsoredLegislation":[{"congress":119}],"pagination":{"count":57}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.sponsored_legislation('S001223', limit: 10)
      expect(response.results).to be_an(Array)
      expect(response.total_count).to be > 0
    end
  end

  describe '#cosponsored_legislation' do
    it 'returns bills cosponsored by the member' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/S001223/cosponsored-legislation})
        .to_return(status: 200, body: '{"cosponsoredLegislation":[{"congress":119}],"pagination":{"count":450}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.cosponsored_legislation('S001223', limit: 10)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list' do
    it 'lists current members' do
      stub_request(:get, %r{api\.congress\.gov/v3/member\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292"}],"pagination":{"count":535}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.list(current: true, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#by_state' do
    it 'lists members from a state' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/VA\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292","state":"Virginia"}],"pagination":{"count":13}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_state(state: 'VA')
      expect(response.results).to be_an(Array)
      expect(response.results.first).to include('bioguideId')
    end

    it 'upcases the state abbreviation' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/OH\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"S001223"}],"pagination":{"count":15}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_state(state: 'oh')
      expect(response.results).not_to be_empty
    end
  end

  describe '#by_state_district' do
    it 'requests the correct path with zero-padded district' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/VA/08\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_state_district(state: 'VA', district: 8)
      expect(response.results).not_to be_empty
    end

    it 'upcases the state abbreviation' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/OH/13\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"S001223"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_state_district(state: 'oh', district: 13)
      expect(response.results.first['bioguideId']).to eq('S001223')
    end
  end

  describe '#by_congress' do
    it 'lists members for a congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119\?})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292"}],"pagination":{"count":535}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = member_resource.by_congress(congress: 119)
      expect(response.results).to be_an(Array)
    end

    it 'omits currentMember when current is nil' do
      stub = stub_request(:get, %r{api\.congress\.gov/v3/member/congress/118\?})
             .with(query: hash_including('limit' => '250', 'offset' => '0'))
             .to_return(status: 200, body: '{"members":[],"pagination":{"count":0}}',
                        headers: { 'Content-Type' => 'application/json' })

      member_resource.by_congress(congress: 118)
      expect(stub).to have_been_requested
    end

    it 'includes currentMember when current is provided' do
      stub = stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119\?})
             .with(query: hash_including('currentMember' => 'true'))
             .to_return(status: 200, body: '{"members":[],"pagination":{"count":0}}',
                        headers: { 'Content-Type' => 'application/json' })

      member_resource.by_congress(congress: 119, current: true)
      expect(stub).to have_been_requested
    end
  end

  describe '#current_for_district' do
    it 'returns a single member hash' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119/VA/08})
        .to_return(status: 200, body: '{"members":[{"bioguideId":"B001292"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      result = member_resource.current_for_district(state: 'VA', district: 8, congress: 119)
      expect(result).to be_a(Hash)
      expect(result).to include('bioguideId')
    end

    it 'returns nil for a district with no current member' do
      stub_request(:get, %r{api\.congress\.gov/v3/member/congress/119/WY/99})
        .to_return(status: 200, body: '{"members":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      result = member_resource.current_for_district(state: 'WY', district: 99, congress: 119)
      expect(result).to be_nil
    end
  end
end
