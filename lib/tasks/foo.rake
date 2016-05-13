# /lib/tasks/dev.rake
# require 'rufus-scheduler'

namespace :foo do

  desc "Testing"
  # task :rebuild => ["db:drop", "db:setup", :fake]

  task :foo => :environment do
    # scheduler = Rufus::Scheduler.singleton
    # # scheduler = Rufus::Scheduler.new
    # scheduler.in '3s' do
    #   puts "ok 1"
    #   Foo.create(title: "Test Data", start_date: DateTime.now)
    #   puts "ok 2"
    # end
  end
end
