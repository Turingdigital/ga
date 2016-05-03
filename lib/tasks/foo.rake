# /lib/tasks/dev.rake
require 'signet/oauth_2/client'
namespace :foo do

  desc "Testing"
  # task :rebuild => ["db:drop", "db:setup", :fake]

  task :foo => :environment do
    p Analytics
  end
end
