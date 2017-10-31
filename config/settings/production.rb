group :action_mailer do
  group :default_url_options do
    set :host, 'former.thecompellingimage.com'
    set :port, 80
  end
end

#
# This setting requires nginx to be configured like this:
#
# location /assets/ {
#   root /var/rails/theia;
#   internal;
# }
#
# Where root is set to the path to the Rails application
#
group :attachment do
  set :send_file_method, :nginx
end

group :purchase do
  group :paypal do
    set :account, 'tuition@thecompellingimage.com'
    set :currency, 'USD'
  end
  group :world_pay do
    set :username, 'O6QQ1G0BEWGY4MBK80ZA'
    set :password, 'n1e2o2##soft54321478'
    set :account, '143169'
    set :currency, 'USD'
    set :security_key, 'blah'
  end
end
