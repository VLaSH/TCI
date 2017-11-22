class LogoUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick
  storage :file

  version :thumb do
    process :resize_to_fit => [160,80]
  end

  def store_dir
    "images/#{model.class.name.pluralize.underscore}/#{mounted_as}/#{("%09d" % model.id).scan(/\d{3}/).join("/")}"
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end

  def default_url
    "/images/default/#{model.class.name.pluralize.underscore}/" + [version_name, ".png"].compact.join('')
  end

end
