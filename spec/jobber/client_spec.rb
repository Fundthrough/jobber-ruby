require "spec_helper"

describe Jobber::Client do
  subject { described_class.new(refresh_token: refresh_token) }

  let(:refresh_token) { "48759483" }

  describe "#refresh_access_token!" do
    let(:token) { double }
    let(:response) { double(:response, body: body) }
    let(:body) { double(:body, access_token: access_token) }
    let(:access_token) do
      [
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9",
        "eyJhcHBfaWQiOiJmdW5kdGhyb3VnaF9kZXYiLCJ1c2VyX2lkIjoyMDYwMzMsImFjY291bnRfaWQiOjY5Njc2LCJleHAiOjE1NzkxOTA1Mzh9",
        "Y3djx61to2LxWd9_xKAkxbIi3WucNnc1o4gh7VXL4Ds"
      ].join(".")
    end

    before do
      allow(Jobber::API::Token).to receive(:new).and_return(token)
      allow(token).to receive(:refresh).and_return(response)

      subject.refresh_access_token!
    end

    it { expect(token).to have_received(:refresh) }
    it { expect(subject.token_expired?).to be_falsy }
  end

  describe "#access_token" do
    before do
      allow(subject).to receive(:token_expired?).and_return(token_expired)
      allow(subject).to receive(:refresh_access_token!)

      subject.access_token
    end

    context "when token is expired" do
      let(:token_expired) { true }

      it { expect(subject).to have_received(:refresh_access_token!) }
    end

    context "when token is valid" do
      let(:token_expired) { false }

      it { expect(subject).to_not have_received(:refresh_access_token!) }
    end
  end

  describe "#token_expired?" do
    before { subject.instance_variable_set(:@token_expired_at, expiration) }

    context "when expiration is nil" do
      let(:expiration) { nil }

      it { expect(subject.token_expired?).to be_truthy }
    end

    context "when expiration is in the past" do
      let(:expiration) { 2.hours.ago }

      it { expect(subject.token_expired?).to be_truthy }
    end

    context "when expiration is in the future" do
      let(:expiration) { 1.hour.from_now }

      it { expect(subject.token_expired?).to be_falsy }
    end
  end

  describe "#token" do
    it { expect(subject.token).to be_instance_of(Jobber::API::Token) }
  end

  describe "#invoice" do
    it { expect(subject.invoice).to be_instance_of(Jobber::API::Invoice) }
  end

  describe "#client" do
    it { expect(subject.client).to be_instance_of(Jobber::API::Client) }
  end

  describe "#transaction" do
    it { expect(subject.transaction).to be_instance_of(Jobber::API::Transaction) }
  end

  describe "#account" do
    it { expect(subject.account).to be_instance_of(Jobber::API::Account) }
  end
end
