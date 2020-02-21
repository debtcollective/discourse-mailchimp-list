# frozen_string_literal: true
require 'rails_helper'

describe Jobs::MailchimpSubscription do
  it "calls upsert with the md5 hashed email" do
    md5_email = Digest::MD5.hexdigest('test@example.com')
    args = {
      email: 'test@example.com',
      name: 'test user',
      list_id: '1234567890',
      api_key: 'testapikeytestapikeytestapikey0c-us8',
    }

    # stub members request
    Sidekiq::Testing.fake! do
      stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/1234567890/members/55502f40dc8b7c769880b10874abc9d0").
        with(
        body: "{\"email_address\":\"test@example.com\",\"status\":\"subscribed\",\"merge_fields\":{\"FNAME\":\"test\",\"LNAME\":\"user\"}}",
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v0.17.3'
        }).
        to_return(status: 200, body: "", headers: {})

      Jobs::MailchimpSubscription.new.execute(args)
    end
  end

  it "calls tags when passing tags" do
    md5_email = Digest::MD5.hexdigest('test@example.com')
    args = {
      email: 'test@example.com',
      name: 'test user',
      list_id: '1234567890',
      api_key: 'testapikeytestapikeytestapikey0c-us8',
      tags: [{ name: "discourse", status: "active" }],
    }

    Sidekiq::Testing.fake! do
      gibbon = Gibbon::Request.new(api_key: args[:api_key])

      # stub members request
      stub_request(:put, "https://us8.api.mailchimp.com/3.0/lists/1234567890/members/55502f40dc8b7c769880b10874abc9d0").
        with(
        body: "{\"email_address\":\"test@example.com\",\"status\":\"subscribed\",\"merge_fields\":{\"FNAME\":\"test\",\"LNAME\":\"user\"}}",
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v0.17.3'
        }).
        to_return(status: 200, body: "", headers: {})

      # stub tags request
      stub_request(:post, "https://us8.api.mailchimp.com/3.0/members/55502f40dc8b7c769880b10874abc9d0/tags").
        with(
        body: "{\"tags\":[{\"name\":\"discourse\",\"status\":\"active\"}]}",
        headers: {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'Authorization' => 'Basic YXBpa2V5OnRlc3RhcGlrZXl0ZXN0YXBpa2V5dGVzdGFwaWtleTBjLXVzOA==',
        'Content-Type' => 'application/json',
        'User-Agent' => 'Faraday v0.17.3'
        }).
        to_return(status: 200, body: "", headers: {})

      Jobs::MailchimpSubscription.new.execute(args)
    end
  end
end
