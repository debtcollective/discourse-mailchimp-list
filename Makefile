default: test

test:
	bundle exec rake plugin:spec["discourse-mailchimp-list"]