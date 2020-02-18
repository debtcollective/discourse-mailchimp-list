# frozen_string_literal: true

# name: DiscourseMailchimpList
# about: Sync Discourse users with a mailchimp list after they signup
# version: 0.1
# authors: orlando
# url: https://github.com/debtcollective/discourse-mailchimp-list

enabled_site_setting :discourse_mailchimp_list_enabled

PLUGIN_NAME ||= 'DiscourseMailchimpList'

gem 'gibbon', '3.3.3'

after_initialize do
  load File.expand_path('../app/jobs/mailchimp_subscription.rb', __FILE__)

  DiscourseEvent.on(:user_created) do |user|
    return unless SiteSettings.discourse_mailchimp_list_enabled

    # get arguments for job
    args = {
      email: user.email,
      name: user.name,
      list_id: SiteSettings.discourse_mailchimp_list_id,
      api_key: SiteSettings.discourse_mailchimp_api_key,
      tags: ['discourse'],
      debug: true
    }

    Jobs.enqueue(:mailchimp_subscription, args)
  end
end
