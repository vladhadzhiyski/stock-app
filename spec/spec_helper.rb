require "rails"
require "pry-byebug"
require File.expand_path('../../config/environment', __FILE__)

Rails.env = ENV["RAILS_ENV"] = "test"

Dir[Rails.root.join("spec/support/**/*.rb")].each do |file|
  require file
end

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  # config.before do
  #   if self.class.metadata[:type] == :controller
  #     @request.headers['Accept'] = Mime[:json].to_s
  #     @request.headers['Content-Type'] = Mime[:json].to_s
  #   end
  # end
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def random_uuid
  SecureRandom.uuid
end

def json_body
  JSON.parse(response.body)
end
