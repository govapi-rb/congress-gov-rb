# frozen_string_literal: true

RSpec.describe CongressGov::Resources::DailyCongressionalRecord do
  subject(:resource) { CongressGov.daily_congressional_record }

  describe '#list' do
    it 'lists daily congressional record volumes' do
      stub_request(:get, %r{api\.congress\.gov/v3/daily-congressional-record\?})
        .to_return(status: 200, body: '{"dailyCongressionalRecord":[{"volumeNumber":"170"}],"pagination":{"count":5}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#list_by_volume' do
    it 'lists issues for a volume' do
      stub_request(:get, %r{api\.congress\.gov/v3/daily-congressional-record/170\?})
        .to_return(status: 200, body: '{"issues":[{"issueNumber":"1"}],"pagination":{"count":3}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list_by_volume(170, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get_issue' do
    it 'fetches a specific issue' do
      stub_request(:get, %r{api\.congress\.gov/v3/daily-congressional-record/170/1})
        .to_return(status: 200, body: '{"issue":{"issueNumber":"1","volumeNumber":"170"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.get_issue(170, 1)
      expect(response['issue']).to include('issueNumber')
    end
  end

  describe '#articles' do
    it 'returns articles for a specific issue' do
      stub_request(:get, %r{api\.congress\.gov/v3/daily-congressional-record/170/1/articles})
        .to_return(status: 200, body: '{"articles":[{"title":"Article 1"}],"pagination":{"count":2}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.articles(170, 1, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end
end
