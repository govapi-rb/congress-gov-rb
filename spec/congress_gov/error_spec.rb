# frozen_string_literal: true

RSpec.describe CongressGov::AuthenticationError do
  it 'inherits from ClientError' do
    expect(described_class.ancestors).to include(CongressGov::ClientError)
  end

  it 'conveys a meaningful message' do
    err = described_class.new('Invalid or missing API key', status: 403)
    expect(err.message).to include('Invalid or missing API key')
    expect(err.status).to eq(403)
  end
end

RSpec.describe CongressGov::ParseError do
  it 'inherits from CongressGov::Error' do
    expect(described_class.ancestors).to include(CongressGov::Error)
  end
end

RSpec.describe CongressGov::NotFoundError do
  it 'inherits from ClientError' do
    expect(described_class.ancestors).to include(CongressGov::ClientError)
  end
end

RSpec.describe CongressGov::RateLimitError do
  it 'inherits from ClientError' do
    expect(described_class.ancestors).to include(CongressGov::ClientError)
  end

  it 'stores status and body' do
    err = described_class.new('Rate limited', status: 429, body: { 'error' => 'too many' })
    expect(err.status).to eq(429)
    expect(err.body).to eq({ 'error' => 'too many' })
  end
end

RSpec.describe CongressGov::ServerError do
  it 'inherits from CongressGov::Error' do
    expect(described_class.ancestors).to include(CongressGov::Error)
  end

  it 'stores status' do
    err = described_class.new(status: 500, body: 'oops')
    expect(err.status).to eq(500)
  end
end

RSpec.describe CongressGov::ConnectionError do
  it 'inherits from CongressGov::Error' do
    expect(described_class.ancestors).to include(CongressGov::Error)
  end
end
