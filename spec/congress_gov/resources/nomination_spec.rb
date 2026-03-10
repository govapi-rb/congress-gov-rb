# frozen_string_literal: true

RSpec.describe CongressGov::Resources::Nomination do
  subject(:nomination_resource) { described_class.new }

  describe '#list' do
    it 'lists all nominations' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination\?})
        .to_return(status: 200, body: '{"nominations":[{"congress":119}],"pagination":{"count":100}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.list(limit: 1)
      expect(response).to be_a(CongressGov::Response)
      expect(response.results).to be_an(Array)
    end

    it 'filters by congress' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119\?})
        .to_return(status: 200, body: '{"nominations":[{"congress":119}],"pagination":{"count":50}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.list(congress: 119, limit: 1)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#get' do
    it 'returns nomination detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119/73})
        .to_return(status: 200, body: '{"nomination":{"congress":119,"number":"73","description":"John Doe"}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.get(119, 73)
      expect(response).to be_a(CongressGov::Response)
      expect(response['nomination']).to include('congress', 'number')
    end
  end

  describe '#get_ordinal' do
    it 'returns nomination ordinal detail' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119/73/1})
        .to_return(status: 200, body: '{"nomination":{"congress":119,"number":"73","ordinal":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.get_ordinal(119, 73, 1)
      expect(response).to be_a(CongressGov::Response)
      expect(response['nomination']).to include('ordinal')
    end
  end

  describe '#actions' do
    it 'returns nomination actions' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119/73/actions})
        .to_return(status: 200, body: '{"actions":[{"actionDate":"2025-03-15","text":"Confirmed"}],"pagination":{"count":2}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.actions(119, 73)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#committees' do
    it 'returns nomination committees' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119/73/committees})
        .to_return(status: 200, body: '{"committees":[{"name":"Judiciary"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.committees(119, 73)
      expect(response.results).to be_an(Array)
    end
  end

  describe '#hearings' do
    it 'returns nomination hearings' do
      stub_request(:get, %r{api\.congress\.gov/v3/nomination/119/73/hearings})
        .to_return(status: 200, body: '{"hearings":[{"date":"2025-04-01"}],"pagination":{"count":1}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = nomination_resource.hearings(119, 73)
      expect(response.results).to be_an(Array)
    end
  end
end
