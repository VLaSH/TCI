# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...


## Deployment
For those who will work later on this project - to restart server after you add any gems, changed config, added initializer, you need just to restart nginx - `sudo service nginx restart`, because passenger restarting built in nginx conf. I'm not an author of this solution, but I had to find out how to apply my changes. If you have any new gems you need to run `bundle install` manually. Here is the flow

* ssh to server
* switch to dbathgate `sudo su dbathgate`
* `cd /home/dbathgate/tci`
* `git pull origin master`
* make sure you using ruby 2.1.2 `rvm use 2.1.2`
* make sure you use global gemset `rvm gemset use global`
* run `bundle install`

After these steps restart server(via nginx restart)
