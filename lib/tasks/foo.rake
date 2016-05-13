# /lib/tasks/dev.rake
require 'signet/oauth_2/client'
namespace :foo do

  desc "Testing"
  # task :rebuild => ["db:drop", "db:setup", :fake]

  task :foo => :environment do
    Foo.create(title: "Test Data", start_date: DateTime.now)
  end
end
