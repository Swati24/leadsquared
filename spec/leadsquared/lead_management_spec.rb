require 'spec_helper'

describe Leadsquared::LeadManagement do
  let(:mock_connection)   { double("connection") }
  let(:invalid_response_body) do
    {
      "Status" => "Error",
      "ExceptionType" => "MXDuplicateEntryException",
      "ExceptionMessage" => "Duplicate entry 'john.smith@acmeconsulting.co' for key 'UQ_Prospect_Base_EmailAddress'"
    }
  end
  let(:invalid_response)  { double("response", status: 500, body: invalid_response_body) }
  let(:service) { '/v2/LeadManagement.svc/' }

  subject { Leadsquared::LeadManagement.new }

  before do
    expect( Leadsquared::Client).to receive(:new).and_return mock_connection
  end

  describe "#create_lead" do
    let(:url) { "#{service}Lead.Create" }
    let(:email) { "test@example.com" }
    let(:first_name) { "Bob" }
    let(:last_name) { "Zeiger" }
    let(:body) do
      [
        {
          "Attribute" => "EmailAddress",
          "Value" => email
        },
        {
          "Attribute" => "FirstName",
          "Value" => first_name
        },
        {
          "Attribute" => "LastName",
          "Value" => last_name
        }
      ]
    end
    let(:success_response) do
      {
        "Status" => "Success",
        "Message" => {
          "Id" => "3131ea6a-bb20-4457-b183-ddf6d8716dfe"
        }
      }
    end
    let(:valid_response)  { double("response", status: 200, body: success_response.to_json) }

    it "valid request with given params" do
      expect(mock_connection).to receive(:post).with(url, {}, body.to_json).and_return valid_response
      response = subject.create_lead(email, first_name, last_name)
      expect(response).to eq(success_response["Message"]["Id"])
    end

    it "invalid request" do
      expect(mock_connection).to receive(:post).with(url, {}, body.to_json).and_return invalid_response
      expect {
        subject.create_lead(email, first_name, last_name)
      }.to raise_error(Leadsquared::InvalidRequestError)
    end
  end

  describe "#get_meta_data" do
    let(:success_response) do
      [
        {
          "SchemaName" => "mx_CreationTime",
          "DisplayName" => "CreationTime",
          "DataType" => "Time",
          "IsMandatory" => false,
          "MaxLength" => "50",
          "RenderType" => 21,
          "RenderTypeTextValue" => "Time"
        },
        {
          "SchemaName" => "mx_ModifiedTime",
          "DisplayName" => "ModifiedTime",
          "DataType" => "Time",
          "IsMandatory" => false,
          "MaxLength" => "50",
          "RenderType" => 21,
          "RenderTypeTextValue" => "Time"
        }]
    end
    let(:valid_response)  { double("response", status: 200, body: success_response.to_json) }
    let(:url) { "#{service}LeadsMetaData.Get" }

    it "valid request with given params" do
      expect(mock_connection).to receive(:get).with(url, {}).and_return valid_response
      response = subject.get_meta_data
    end

  end
end
