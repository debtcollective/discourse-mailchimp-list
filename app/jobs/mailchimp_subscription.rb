# frozen_string_literal: true
module Jobs
  class MailchimpSubscription < ::Jobs::Base
    def execute(args)
      email = args[:email]
      name = args[:name]
      list_id = args[:list_id]
      api_key = args[:api_key]
      debug = args[:debug]
      tags = args[:tags] || []

      # init Gibbon
      gibbon = Gibbon::Request.new(api_key: api_key, debug: debug)
      gibbon_list = gibbon.lists(list_id)

      # naive approach to split full name in first and last
      first_name, *last_name = name.split(' ')
      last_name = last_name.join(' ')

      email_digest = Digest::MD5.hexdigest(email.downcase)

      # add user to list
      gibbon_list
        .members(email_digest)
        .upsert(body: {
          email_address: email,
          status: "subscribed",
          merge_fields: {
            FNAME: first_name,
            LNAME: last_name,
          }
        })

      # add tags to user
      gibbon_list
        .members(email_digest)
        .tags
        .create(body: {
          tags: tags
        })
    rescue Gibbon::MailChimpError => e
      Raven.capture_exception(e) if defined?(Raven)
    end
  end
end
