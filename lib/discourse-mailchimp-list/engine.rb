module DiscourseMailchimpList
  class Engine < ::Rails::Engine
    engine_name "DiscourseMailchimpList".freeze
    isolate_namespace DiscourseMailchimpList

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::DiscourseMailchimpList::Engine, at: "/discourse-mailchimp-list"
      end
    end
  end
end
