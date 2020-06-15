# frozen_string_literal: true
require 'rails_helper'

describe Jobs::MailchimpSubscription do
  describe("#execute") do
    before do
      phone_user_field = Fabricate(:user_field, name: "Phone Number")
      @user = Fabricate(:user,
        email: "test@example.com",
        name: "Bruce Wayne",
        custom_fields: { "user_field_#{phone_user_field.id}": "800123123123" }
      )

      SiteSetting.discourse_mailchimp_api_key = "testapikeytestapikeytestapikey0c-us8"
      SiteSetting.discourse_mailchimp_list_id = "1234567890"
    end

    it "calls upsert with the md5 hashed email" do
      md5_email = Digest::MD5.hexdigest(@user.email)
      args = {
        user_id: @user.id,
        debug: true
      }

      Sidekiq::Testing.fake! do
        # stub members request
        stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/1234567890/members/55502f40dc8b7c769880b10874abc9d0").
          with(
            body: "{\"email_address\":\"test@example.com\",\"status\":\"subscribed\",\"ip_signup\":\"\",\"merge_fields\":{\"FNAME\":\"Bruce\",\"LNAME\":\"Wayne\",\"PHONE\":\"800123123123\"}}",
            headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v1.0.1'
            }).
          to_return(status: 200, body: "", headers: {})

          Jobs::MailchimpSubscription.new.execute(args)
      end
    end

    it "calls tags when passing tags" do
      md5_email = Digest::MD5.hexdigest(@user.email)
      args = {
        user_id: @user.id,
        debug: true,
        tags: [{ name: "discourse", status: "active" }],
      }

      Sidekiq::Testing.fake! do
        # stub members request
        stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/1234567890/members/55502f40dc8b7c769880b10874abc9d0").
          with(
            body: "{\"email_address\":\"test@example.com\",\"status\":\"subscribed\",\"ip_signup\":\"\",\"merge_fields\":{\"FNAME\":\"Bruce\",\"LNAME\":\"Wayne\",\"PHONE\":\"800123123123\"}}",
            headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v1.0.1'
            }).
          to_return(status: 200, body: "", headers: {})

        # stub tags request
        stub_request(:post, "https://us8.api.mailchimp.com/3.0/lists/1234567890/members/55502f40dc8b7c769880b10874abc9d0/tags").
          with(
            body: "{\"tags\":[{\"name\":\"discourse\",\"status\":\"active\"}]}",
            headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Faraday v1.0.1'
            }).
          to_return(status: 200, body: "", headers: {})

        Jobs::MailchimpSubscription.new.execute(args)
      end
    end
  end
end
