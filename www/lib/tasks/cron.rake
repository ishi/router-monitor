namespace :cron do
  desc "Run cron tasks"
  task :minute => :environment do
    puts 'Minute :)'
  end
end
