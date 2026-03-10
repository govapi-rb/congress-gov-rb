# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Summary do
  subject(:summary_resource) { CongressGov.summary }

  describe '#list' do
    it 'lists all summaries' do
      stub_request(:get, %r{api\.congress\.gov/v3/summaries\?})
        .to_return(status: 200, body: '{"summaries":[{"text":"Summary text","bill":{"number":"1"}}],"pagination":{"count":100}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = summary_resource.list(limit: 1)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/summaries/119\?})
        .to_return(status: 200, body: '{"summaries":[{"text":"Summary text"}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = summary_resource.list(congress: 119, limit: 1)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress and bill type' do
      stub_request(:get, %r{api\.congress\.gov/v3/summaries/119/hr\?})
        .to_return(status: 200, body: '{"summaries":[{"text":"HR summary"}],"pagination":{"count":25}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = summary_resource.list(congress: 119, bill_type: 'hr', limit: 1)
      expect(response.results).to be_an(Array)
    end
  end
end
