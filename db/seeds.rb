# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add the default administrator account
    User.reset_column_information
    administrator = User.new(:email => 'admin@thecompellingimage.com',
                             :password_confirmation => 'testing',
                             :given_name => 'Admin',
                             :family_name => 'User')
    administrator.password = 'testing'
    p administrator
    administrator.status = 'activated'
    administrator.role = 'a'
    administrator.save(validate: false)

# Bellow code use for give number for every course type
[
  {title: "Photography", number: 1},
  {title: "Video-Production", number: 2},
  {title: "Multimedia", number: 3}
].each do |k|
  ct = CourseType.find_or_initialize_by(title: k[:title])
  ct.number = k[:number]
  ct.save
end
[
  {key: "banner_slide_speed", value: "8500", method: "to_i"},
  {key: "video_url", value: "https://www.youtube.com/embed/M7lc1UVf-VE?autoplay=1&origin=", method: 2},
  {key: "sample course", value: nil, method: nil}
].each do |k|
  setting = Settings.find_or_initialize_by(key: k[:key])
  setting.assign_attributes(k)
  setting.save
end
