# rake setup:add_default_scheduled_courses RAILS_ENV=production

namespace :setup do

  task :add_default_scheduled_courses => :environment do
    Course.all.select{|c| c.scheduled_courses.count.zero? }.each do |course|
      course.scheduled_courses.build.save
    end
  end
end
