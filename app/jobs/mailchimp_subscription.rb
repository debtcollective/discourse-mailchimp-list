# frozen_string_literal: true
module Jobs
  class MailchimpSubscription < ::Jobs::Base
    def execute(args)
      api_key = SiteSetting.discourse_mailchimp_api_key
      list_id = SiteSetting.discourse_mailchimp_list_id
      debug = !!args[:debug]
      tags = args[:tags] || []

      return unless api_key && list_id

      # Find user
      user_id = args[:user_id]
      user = User.find(user_id)
      email = user.email
      name = user.name

      # init Gibbon
      gibbon = Gibbon::Request.new(api_key: api_key, debug: debug)

      # naive approach to split full name in first and last
      first_name, *last_name = name.split(' ')
      last_name = last_name.join(' ')

      ip_signup = user.registration_ip_address.to_s
      email_digest = Digest::MD5.hexdigest(email.downcase)

      # Get phone number
      # TODO: Move this Discourse Settings, so it can be used by others
      # Right now it is specific to our implementation
      phone_number_field = UserField.find_by(name: "Phone Number")
      phone_number = user.user_fields.fetch(phone_number_field.id.to_s, "") if phone_number_field

      # add user to list
      gibbon
        .lists(list_id)
        .members(email_digest)
        .upsert(body: {
          email_address: email,
          status: "subscribed",
          ip_signup: ip_signup,
          merge_fields: {
            FNAME: first_name,
            LNAME: last_name,
            PHONE: phone_number,
          }
        })

      # add tags to user
      if tags.any?
        gibbon
          .lists(list_id)
          .members(email_digest)
          .tags
          .create(body: {
            tags: tags
          })
      end
    rescue Gibbon::MailChimpError => e
      Raven.capture_exception(e) if defined?(Raven)
    end
  end
end
