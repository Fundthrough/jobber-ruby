require "spec_helper"

describe Jobber::API::Base do
  subject { described_class.new(jobber_client) }

  let(:jobber_client) { double(:client, access_token: access_token) }
  let(:access_token) { "token" }
  let(:default_headers) do
    {
      "API-ACCESS-TOKEN" => "token",
      "X-API-SIDE-LOADING-ENABLED" => "true",
      "X-API-VERSION" => "3.3.0"
    }
  end
  before do
    allow(::Jobber::Fetcher).to receive(:request)
    allow(jobber_client).to receive(:refresh_access_token!)
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe "#request" do
    context "without opts" do
      before { subject.request(:get, "/voice") }

      it { expect(::Jobber::Fetcher).to have_received(:request).with(:get, "/voice", headers: default_headers) }
    end

    context "with query opt" do
      before { subject.request(:get, "/voice", query: query) }

      let(:headers) { default_headers }
      let(:query) { { page: 1 } }

      it { expect(::Jobber::Fetcher).to have_received(:request).with(:get, "/voice", query: query, headers: headers) }
    end

    context "with query & headers opt" do
      before { subject.request(:get, "/voice", query: query, headers: { ping: "pong" }) }

      let(:headers) { { ping: "pong" }.merge(default_headers) }
      let(:query) { { page: 1 } }

      it { expect(::Jobber::Fetcher).to have_received(:request).with(:get, "/voice", query: query, headers: headers) }
    end

    context "with authorization error" do
      before do
        @times_called = 0
        allow(::Jobber::Fetcher).to receive(:request) do
          @times_called += 1
          raise Jobber::AuthorizationError if @times_called == 1
        end
        subject.request(:get, "/voice")
      end

      it { expect(jobber_client).to have_received(:refresh_access_token!) }
    end
  end
end
