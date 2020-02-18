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

      # add user to list
      gibbon_list
        .members(lower_case_md5_hashed_email_address)
        .upsert(body: {
          email_address: email,
          status: "subscribed",
          merge_fields: {
            FNAME: first_name,
            LNAME: last_name,
          }
        })

      # add tags to user
      if tags.any?
        gibbon_list
          .members(Digest::MD5.hexdigest(lower_case_email_address))
          .tags
          .create(
            body: {
              tags: tags
            }
          )
      end
    rescue Gibbon::MailChimpError => e
      Raven.capture_exception(e) if defined?(Raven)
    end
  end
end
