namespace :home_banner do
  task add_type_in_banner_images: :environment do
    BannerImage.update_all(type: 'HomeBanner')
  end
end
