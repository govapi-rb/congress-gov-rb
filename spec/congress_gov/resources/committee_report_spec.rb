# frozen_string_literal: true

RSpec.describe CongressGov::Resources::CommitteeReport do
  subject(:resource) { CongressGov.committee_report }

  describe '#list' do
    it 'lists all committee reports' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-report\?})
        .to_return(status: 200, body: '{"committeeReports":[{"citation":"H. Rpt. 119-1"}],"pagination":{"count":10}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-report/119\?})
        .to_return(status: 200, body: '{"committeeReports":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, limit: 1)
      expect(response.results).to eq([])
    end

    it 'filters by congress and report type' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-report/119/hrpt\?})
        .to_return(status: 200, body: '{"committeeReports":[],"pagination":{"count":0}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(congress: 119, report_type: 'hrpt', limit: 1)
      expect(response.results).to eq([])
    end

    it 'raises ArgumentError for invalid report type' do
      expect { resource.list(congress: 119, report_type: 'invalid') }.to raise_error(ArgumentError, /report type/)
    end
  end

  describe '#get' do
    it 'fetches a specific committee report' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-report/119/hrpt/1})
        .to_return(status: 200, body: '{"committeeReport":{"citation":"H. Rpt. 119-1"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(119, 'hrpt', 1)
      expect(response['committeeReport']).to include('citation')
    end

    it 'raises ArgumentError for invalid report type' do
      expect { resource.get(119, 'invalid', 1) }.to raise_error(ArgumentError, /report type/)
    end
  end

  describe '#text' do
    it 'returns text versions of a committee report' do
      stub_request(:get, %r{api\.congress\.gov/v3/committee-report/119/srpt/5/text})
        .to_return(status: 200, body: '{"textVersions":[{"type":"Reported"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.text(119, 'srpt', 5)
      expect(response.results).to be_an(Array)
    end
  end
end
