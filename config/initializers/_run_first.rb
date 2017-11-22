# This is a bit of a hack - initializers are called alphabetically and the order cannot be changed, so this
# initializer should be used for anything that needs to be initialised before the other initializers run

# Require and initialise any monkey-patches used by the application (patch code lives in lib/patches)
#TODO fix this


#Load application configuration settings
SimpleConfig.for :application do
  load File.join(Rails.root, 'config', 'settings', 'common.rb'),       :if_exists? => true
  load File.join(Rails.root, 'config', 'settings', "#{Rails.env}.rb"), :if_exists? => true
  load File.join(Rails.root, 'config', 'settings', 'local.rb'),        :if_exists? => true
end

unless ActionController::Base.private_instance_methods.include? 'template_exists?'
  def template_exists?(path)
    self.view_paths.find_template(path, response.template.template_format)
  rescue ActionView::MissingTemplate
    false
  end
end

Dir[File.join(Rails.root, 'lib', 'patches', '**', '*.rb')].sort.each { |patch| require(patch) }