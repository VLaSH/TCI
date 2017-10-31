# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += ['*.js', '*.css', '**/*.js', '**/*.css']
# Rails.application.config.assets.precompile += %w( reset.css 960.css text.css tci.css uni-form.css lightview.css pretty_buttons.css prototip.css slides.jquery.js jquery.easing.1.3.js jquery.lightbox.js prototype.js, uni-form.prototype.js prototype.js uni-form.prototype.js)
