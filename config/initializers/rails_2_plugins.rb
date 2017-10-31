# # Include hook code here
require 'pretty_buttons'
require 'country_codes/country_codes'
require 'uni_form'

# pretty_buttons
ActionView::Base.send :include, PrettyButtons

# uniformfor
ActionView::Base.send(:include, UniForm::UniFormHelper)
ActionView::Helpers::FormBuilder.send(:include, UniForm::FormBuilderMethods)

#country_codes
CountryCodes.load_countries_from_yaml
