Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '817870141667507', 'b5261d4a053bbd386a50ba1753907094',
           :scope => 'email,user_birthday,public_profile, user_location,user_hometown'
end
