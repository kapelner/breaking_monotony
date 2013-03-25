class CronJob < ActiveRecord::Base
  serialize :data

  CronJob.partial_updates = false

  def CronJob.run(name)
    #data is returned from the function itself
    data = case name
             when :approve_or_reject_hits
               Worker.approve_or_reject_hits
             when :create_hits
               MHit.create_hit_set_for_both_india_and_us
             else
               raise "invalid cron job '#{name.to_s}'"
           end

    #create a record that this job ran, and record its data
    CronJob.create(:name => name.to_s, :data => data)
  end

end

=begin
Crons to set up:
1) the cron that creates HITs
0,15,30,45 * * * *
cd /data/<anonymized>/current && bundle exec rails runner -e production 'CronJob.run(:create_hits)'
2) the cron that pays workers
25 * * * *
cd /data/<anonymized>/current && bundle exec rails runner -e production 'CronJob.run(:approve_or_reject_hits)'
=end

#### error workers: 111, 199, 299, 338, 449, 655, 2812, 3190, 3446, 3640, 3956, 4295
