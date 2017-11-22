#run rake task
#rake set:duration
#then rake db:migrate
namespace :set do
  task :duration => :environment do
    Course.all.each do |course|
      duration = course.lessons.map(&:duration).sum
      course.update_attributes(duration: duration)
    end
  end
end