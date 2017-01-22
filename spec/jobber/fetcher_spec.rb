require "spec_helper"

describe Jobber::Fetcher do
  let(:method) { :post }
  let(:endpoint) { "/v1/invoices" }
  let(:opts) { { body: request_body, headers: request_headers, query: query } }
  let(:request_body) { { client: { username: "Vivo", first_name: "Jemmy", last_name: "Vardy" } } }
  let(:request_headers) { { "Custom-Header" => "3424343" } }
  let(:query) { { type: "active" } }
  let(:response) { double(:response, body: body, headers: headers, code: code, success?: true) }
  let(:body) { '{"client":{"id":"121"}}' }
  let(:headers) { { "Content-Type" => "application/json" } }
  let(:code) { 200 }
  let(:configs) { double(:configs, app_key: "key", max_retries: 1, verbose: false) }

  before { allow(Jobber).to receive(:configs).and_return(configs) }

  describe ".request" do
    subject { described_class.request(method, endpoint, opts) }

    context "with connection errors" do
      let(:error) { double }

      context "Connection error" do
        before { allow(error).to receive(:code).and_raise(Net::ReadTimeout) }

        context "return error only after one try" do
          before { allow(described_class).to receive(method).and_return(error, response) }

          it { expect { subject }.to_not raise_error }
        end

        context "return error after two tries" do
          before { allow(described_class).to receive(method).and_return(error, error, response) }

          it { expect { subject }.to raise_error(Net::ReadTimeout) }
        end
      end

      context "Server error" do
        let(:code) { 500 }

        before { allow(described_class).to receive(:post).and_return(response) }

        it { expect { subject }.to raise_error(Jobber::ApiServerError) }
      end

      context "Auth error" do
        let(:code) { 401 }

        before { allow(described_class).to receive(:post).and_return(response) }

        it { expect { subject }.to raise_error(Jobber::AuthorizationError) }
      end
    end

    context "without connection errors" do
      let(:request_opts) { { body: json_body, headers: request_headers, query: query } }
      let(:json_body) { { client: { "username": "Vivo", "first_name": "Jemmy", "last_name": "Vardy" } } }

      before do
        allow(described_class).to receive(method).and_return(response)
        subject
      end

      context "with json response" do
        it { expect(described_class).to have_received(:post).with(endpoint, request_opts) }
        it { expect(subject.success?).to be_truthy }
        it { expect(subject.status_code).to eq(200) }
        it { expect(subject.body).to be_kind_of(Hashie::Mash) }
        it { expect(subject.body.client.id).to eq("121") }
        it { expect(subject.headers).to eq(headers) }
      end

      context "with string response" do
        let(:body) { "OK!" }

        it { expect(subject.body).to eq(body) }
      end
    end
  end
end
