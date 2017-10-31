require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'csv'
require 'money'
require 'money/bank/google_currency'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TciNew
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
   
    config.active_record.observers = :assignment_submission_observer, :critique_observer, :enquiry_observer, :enrolment_observer, :forum_post_observer, :scheduled_assignment_observer, :scheduled_lesson_observer, :user_observer
    config.autoload_paths << Rails.root.join('lib')
    config.after_initialize do
      ActionView::Base.sanitized_allowed_tags.delete 'p'
    end
    Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
    Money::Bank::GoogleCurrency::SERVICE_HOST="finance.google.com"
    Money.default_bank = Money::Bank::GoogleCurrency.new	
    config.assets.paths << "#{Rails.root}/app/assets/fonts"
     config.assets.precompile += ['pdf.css']
  end
end


