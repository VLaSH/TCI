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
