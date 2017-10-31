Rails.application.configure do
  config.action_mailer.default_options = {from: 'TheCompellingImage <announcements@thecompellingimage.com>'}
end
group :action_mailer do
  group :default_mail_from do
    set :name, 'TheCompellingImage'
    set :address, 'announcements@thecompellingimage.com'
  end
  group :default_url_options do
    set :protocol, 'https'
    set :host, 'localhost'
    set :port, 3000
  end
end

group :active_merchant do
  set :mode, (Rails.env.production? ? :production : :test)
end

group :paperclip do
  set :audio_content_types, [ 'audio/x-wav', 'audio/mpeg' ]
  set :image_content_types, [ 'image/bmp',
                              'image/gif',
                                 'image/png',
                                 'image/x-png',
                                 'image/jpeg',
                                 'image/pjpeg',
                                 'image/jpg',
                                 'image/tiff' ]
  set :video_content_types, [ 'application/x-flash-video',
                                 'application/x-flv',
                                 'application/x-mp4',
                                 'application/x-mov',
                                 'video/mpeg',
                                 'video/quicktime',
                                 'video/x-la-asf',
                                 'video/x-ms-asf',
                              'video/x-ms-wmv',
                                 'video/x-msvideo',
                                 'video/x-sgi-movie',
                                 'video/x-flv',
                                 'flv-application/octet-stream',
                                 'video/3gpp',
                                 'video/3gpp2',
                                 'video/3gpp-tt',
                                 'video/bmpeg',
                                 'video/bt656',
                                 'video/celb',
                                 'video/dv',
                                 'video/h261',
                                 'video/h263',
                                 'video/h263-1998',
                                 'video/h263-2000',
                                 'video/h264',
                                 'video/jpeg',
                                 'video/mj2',
                                 'video/mp1s',
                                 'video/mp2p',
                                 'video/mp2t',
                                 'video/mp4',
                                 'video/mp4v-es',
                                 'video/mpv',
                                 'video/mpeg4',
                                 'video/mpeg4-generic',
                                 'video/nv',
                                 'video/parityfec',
                                 'video/pointer',
                                 'video/raw',
                                 'video/rtx' ]
end

group :purchase do
  group :paypal do
    set :account, 'tci_1288728466_biz@thewebfellas.com'
    set :currency, 'USD'
  end
  group :world_pay do
    set :username, 'O6QQ1G0BEWGY4MBK80ZA'
    set :password, 'n1e2o2##soft54321478'
    set :account, '143169'
    set :currency, 'USD'
    set :security_key, 'power'
  end
  group :stripe do
    set :currency, 'USD'
  end
end

group :attachment do
  set :file_exists_timeout, 1.hour
  set :maximum_asset_size, 100.megabytes
  set :send_file_method, :default
end

group :course do
  set :maximum_photo_size, 8.megabytes
  set :minimum_scheduled, 6
end

group :lesson do
  set :maximum_photo_size, 8.megabytes
end

group :user do
  set :temporary_password_length, 10
  set :temporary_password_duration, 1.day
  set :last_seen_at_duration, 15.minutes
  set :last_seen_at_update_frequency, 2.minutes
  set :remember_email_duration, 6.months
  set :maximum_photo_size, 8.megabytes
end


group :mailchimp do
  set :api_key, 'blah'
end
