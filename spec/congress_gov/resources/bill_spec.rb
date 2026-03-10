# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Bill do
  subject(:bill_resource) { CongressGov.bill }

  describe '#get' do
    it 'returns bill detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371})
        .to_return(status: 200, body: '{"bill":{"number":"5371","title":"Continuing Appropriations Act"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.get(119, 'hr', 5371)
      expect(response).to be_a(CongressGov::Response)
      expect(response['bill']).to include('number', 'title')
    end

    it 'raises ArgumentError for invalid bill type' do
      expect { bill_resource.get(119, 'zz', 1) }.to raise_error(ArgumentError, /bill type/)
    end
  end

  describe '#actions' do
    it 'returns bill actions' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/actions})
        .to_return(status: 200, body: '{"actions":[{"actionDate":"2025-09-19","text":"Passed House"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.actions(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#house_vote_references' do
    it 'extracts recorded vote references from bill actions' do
      actions_body = {
        'actions' => [
          {
            'actionDate' => '2025-09-19',
            'text' => 'On passage',
            'recordedVotes' => [
              {
                'chamber' => 'House',
                'rollNumber' => 281,
                'sessionNumber' => 1,
                'congress' => 119,
                'url' => 'https://clerk.house.gov/evs/2025/roll281.xml'
              }
            ]
          },
          { 'actionDate' => '2025-09-18', 'text' => 'Rule adopted' }
        ],
        'pagination' => { 'count' => 2 }
      }

      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/actions})
        .to_return(status: 200, body: actions_body.to_json,
                   headers: { 'Content-Type' => 'application/json' })

      refs = bill_resource.house_vote_references(119, 'hr', 5371)
      expect(refs).to be_an(Array)
      expect(refs.length).to eq(1)
      ref = refs.first
      expect(ref['rollNumber']).to eq(281)
      expect(ref['chamber']).to eq('House')
      expect(ref['url']).to match(/clerk\.house\.gov/)
    end
  end

  describe '#subjects' do
    it 'returns subjects' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/subjects})
        .to_return(status: 200, body: '{"subjects":{"legislativeSubjects":[]},"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.subjects(119, 'hr', 5371)
      expect(response).to be_a(CongressGov::Response)
    end
  end

  describe '#summaries' do
    it 'returns summaries' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/summaries})
        .to_return(status: 200, body: '{"summaries":[{"text":"Summary text"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.summaries(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#cosponsors' do
    it 'returns cosponsors' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/cosponsors})
        .to_return(status: 200, body: '{"cosponsors":[{"bioguideId":"B001292"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.cosponsors(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#amendments' do
    it 'returns amendments' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/amendments})
        .to_return(status: 200, body: '{"amendments":[{"number":"1"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.amendments(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#committees' do
    it 'returns committees' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/committees})
        .to_return(status: 200, body: '{"committees":[{"name":"Appropriations"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.committees(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#related_bills' do
    it 'returns related bills' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/relatedbills})
        .to_return(status: 200, body: '{"relatedBills":[{"number":"1234"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.related_bills(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#text' do
    it 'returns text versions' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/text})
        .to_return(status: 200, body: '{"textVersions":[{"type":"Introduced"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.text(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#titles' do
    it 'returns titles' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr/5371/titles})
        .to_return(status: 200, body: '{"titles":[{"title":"Continuing Appropriations Act"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.titles(119, 'hr', 5371)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list' do
    it 'lists bills' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill\?})
        .to_return(status: 200, body: '{"bills":[{"number":"5371"}],"pagination":{"count":100}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119\?})
        .to_return(status: 200, body: '{"bills":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.list(congress: 119, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and bill type' do
      stub_request(:get, %r{api\.congress\.gov/v3/bill/119/hr\?})
        .to_return(status: 200, body: '{"bills":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = bill_resource.list(congress: 119, bill_type: 'hr', limit: 1)
      expect(response.results).to eq([])
    end
  end
end
