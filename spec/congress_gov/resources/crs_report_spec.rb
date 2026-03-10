# frozen_string_literal: true

RSpec.describe CongressGov::Resources::CrsReport do
  subject(:resource) { CongressGov.crs_report }

  describe '#list' do
    it 'lists CRS reports' do
      stub_request(:get, %r{api\.congress\.gov/v3/crsreport\?})
        .to_return(status: 200, body: '{"crsReports":[{"title":"Report on Tax Policy"}],"pagination":{"count":10}}',
                   headers: { 'Content-Type' => 'application/json' })

      response = resource.list(limit: 1)
      expect(response.results).to be_an(Array)
    end
  end
end
