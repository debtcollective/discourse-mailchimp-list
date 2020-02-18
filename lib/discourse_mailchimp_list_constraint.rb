class DiscourseMailchimpListConstraint
  def matches?(request)
    SiteSetting.discourse_mailchimp_list_enabled
  end
end
