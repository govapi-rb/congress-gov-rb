# frozen_string_literal: true

RSpec.describe CongressGov::Resources::BoundCongressionalRecord do
  subject(:resource) { CongressGov.bound_congressional_record }

  describe '#list' do
    it 'lists bound congressional record years' do
      stub_request(:get, %r{api\.congress\.gov/v3/bound-congressional-record\?})
        .to_return(status: 200, body: '{"boundCongressionalRecord":[{"year":"2024"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list_by_year' do
    it 'lists records for a specific year' do
      stub_request(:get, %r{api\.congress\.gov/v3/bound-congressional-record/2024\?})
        .to_return(status: 200, body: '{"boundCongressionalRecord":[{"month":"01"}],"pagination":{"count":12}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list_by_year(2024, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list_by_month' do
    it 'lists records for a specific year and month' do
      stub_request(:get, %r{api\.congress\.gov/v3/bound-congressional-record/2024/01\?})
        .to_return(status: 200, body: '{"boundCongressionalRecord":[{"day":"15"}],"pagination":{"count":20}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list_by_month(2024, '01', limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'fetches a specific date record' do
      stub_request(:get, %r{api\.congress\.gov/v3/bound-congressional-record/2024/01/15})
        .to_return(status: 200, body: '{"boundCongressionalRecord":{"date":"2024-01-15"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get(2024, '01', '15')
      expect(response['boundCongressionalRecord']).to include('date')
    end
  end
end
