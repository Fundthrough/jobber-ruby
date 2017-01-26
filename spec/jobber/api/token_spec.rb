require "spec_helper"

describe Jobber::API::Token do
  subject { described_class.new(jobber_client) }

  let(:jobber_client) { double(:client, refresh_token: refresh_token) }
  let(:refresh_token) { "384593485" }
  let(:configs) { double(:configs, client_id: "key", client_secret: "sec") }

  before do
    allow(::Jobber::Fetcher).to receive(:request)
    allow(Jobber).to receive(:configs).and_return(configs)
  end

  describe "#refresh" do
    context "with successful response" do
      before { subject.refresh }

      let(:query) do
        {
          client_id:      "key",
          client_secret:  "sec",
          refresh_token:  refresh_token,
          grant_type:     "refresh_token"
        }
      end

      it { expect(::Jobber::Fetcher).to have_received(:request).with(:post, "/oauth/token", query: query) }
    end

    context "with authorization error" do
      before { allow(::Jobber::Fetcher).to receive(:request).and_raise(Jobber::AuthorizationError) }

      it { expect { subject.refresh }.to raise_error(Jobber::AccessTokenRefreshError) }
    end
  end

  describe "#revoke" do
    before { subject.revoke }

    let(:query) { { refresh_token: refresh_token } }

    it { expect(::Jobber::Fetcher).to have_received(:request).with(:get, "/oauth/revoke", query: query) }
  end
end
