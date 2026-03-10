# frozen_string_literal: true

RSpec.describe CongressGov::Resources::HouseVote do
  subject(:house_vote_resource) { CongressGov.house_vote }

  describe '#list_all' do
    it 'lists all votes without parameters' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote\?})
        .to_return(status: 200, body: '{"houseVotes":[{"rollNumber":281}],"pagination":{"count":500}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = house_vote_resource.list_all(limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list_by_congress' do
    it 'lists votes for a specific congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119\?})
        .to_return(status: 200, body: '{"houseVotes":[{"rollNumber":281}],"pagination":{"count":300}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = house_vote_resource.list_by_congress(congress: 119, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list' do
    it 'lists votes for a congress and session' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119/1\?})
        .to_return(status: 200, body: '{"houseVotes":[{"rollNumber":281}],"pagination":{"count":300}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = house_vote_resource.list(congress: 119, session: 1, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'returns vote metadata' do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119/1/281\?})
        .to_return(status: 200, body: '{"houseVote":{"rollNumber":281,"result":"Passed"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = house_vote_resource.get(congress: 119, session: 1, roll_call: 281)
      expect(response).to be_a(CongressGov::Response)
    end
  end

  describe '#members' do
    let(:members_body) do
      {
        'members' => [
          { 'bioguideId' => 'B001292', 'voteCast' => 'Nay', 'firstName' => 'Donald', 'lastName' => 'Beyer' },
          { 'bioguideId' => 'A000055', 'voteCast' => 'Aye', 'firstName' => 'Robert', 'lastName' => 'Aderholt' }
        ],
        'pagination' => { 'count' => 2 }
      }
    end

    before do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119/1/281/members})
        .to_return(status: 200, body: members_body.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns per-member vote positions' do
      response = house_vote_resource.members(congress: 119, session: 1, roll_call: 281)
      expect(response.results).to be_an(Array)
      member = response.results.first
      expect(member).to include('bioguideId', 'voteCast')
      expect(['Aye', 'Nay', 'Present', 'Not Voting']).to include(member['voteCast'])
    end
  end

  describe '#member_votes_by_bioguide' do
    let(:members_body) do
      {
        'members' => [
          { 'bioguideId' => 'B001292', 'voteCast' => 'Nay' },
          { 'bioguideId' => 'A000055', 'voteCast' => 'Aye' }
        ],
        'pagination' => { 'count' => 2 }
      }
    end

    before do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119/1/281/members})
        .to_return(status: 200, body: members_body.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns a hash keyed by bioguide ID' do
      votes = house_vote_resource.member_votes_by_bioguide(congress: 119, session: 1, roll_call: 281)
      expect(votes).to be_a(Hash)
      expect(votes['B001292']).to eq('Nay')
      expect(votes['A000055']).to eq('Aye')
    end
  end

  describe '#position_for_member' do
    let(:members_body) do
      {
        'members' => [
          { 'bioguideId' => 'B001292', 'voteCast' => 'Nay' },
          { 'bioguideId' => 'A000055', 'voteCast' => 'Aye' }
        ],
        'pagination' => { 'count' => 2 }
      }
    end

    before do
      stub_request(:get, %r{api\.congress\.gov/v3/house-vote/119/1/281/members})
        .to_return(status: 200, body: members_body.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns the vote position for a specific member' do
      position = house_vote_resource.position_for_member(
        congress: 119, session: 1, roll_call: 281, bioguide_id: 'B001292'
      )
      expect(position).to eq('Nay')
    end

    it 'returns nil for a bioguide ID not in the vote' do
      position = house_vote_resource.position_for_member(
        congress: 119, session: 1, roll_call: 281, bioguide_id: 'Z999999'
      )
      expect(position).to be_nil
    end
  end
end
