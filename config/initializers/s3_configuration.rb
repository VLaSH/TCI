if Rails.application.config.s3_configuration
  S3_CREDENTIALS = {
    :storage => :s3,
    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
    :url => ':s3_domain_url'
  }

  USER_PHOTO_STORAGE = S3_CREDENTIALS.merge({
    path: ':class/photo/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/photo/:style.gif'
  })

  USER_INSTRUCTOR_PHOTO = S3_CREDENTIALS.merge({
    :path => ':class/instructor_photo/:id_partition/:style.:extension',
    :default_url => '/images/defaults/:class/instructor_photo/:style.gif'
  })

  ASSETS_FILES = S3_CREDENTIALS.merge({
    path: ':class/:id_partition/:style.:content_type_extension',
    default_url: '/images/defaults/:class/:style.gif',
    s3_protocol: 'http',
  })

  COURSE_PHOTO = S3_CREDENTIALS.merge({
    path: '/:class/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/:style.gif'
  })

  PACKAGE_PHOTO = S3_CREDENTIALS.merge({
    path: '/:class/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/:style.gif'
  })

  LESSON_IMAGE = S3_CREDENTIALS.merge({
    path: ':class/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/:style.gif'
  })

  BANNER_IMAGE = S3_CREDENTIALS.merge({
    path: 'banner_images/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/:style.gif'
  })
  STUDENTGALLERY_IMAGE = S3_CREDENTIALS.merge({
    path: ':class/:id_partition/:style.:extension',
    default_url: '/images/defaults/:class/:style.gif'
  })

else
  USER_PHOTO_STORAGE = {
    path: 'public/images/:class/photo/:id_partition/:style.:extension',
    url: '/images/:class/photo/:id_partition/:style.:extension',
    default_url: '/defaults/user.jpeg'
  }

  USER_INSTRUCTOR_PHOTO = {
    path: 'public/images/:class/instructor_photo/:id_partition/:style.:extension',
    url: '/images/:class/instructor_photo/:id_partition/:style.:extension',
    default_url: '/defaults/user.jpeg'
  }

  ASSETS_FILES = {
    path: 'public/images/:class/:id_partition/:style.:content_type_extension',
    url: '/images/:class/:id_partition/:style.:content_type_extension',
    default_url: '/defaults/user.jpeg'
  }

  COURSE_PHOTO = {
    path: 'public/images/:class/:id_partition/:style.:extension',
    url: '/images/:class/:id_partition/:style.:extension',
    default_url: '/assets/courses-banner/courses-adventure.jpg'
  }

  PACKAGE_PHOTO = {
    path: 'public/images/:class/:id_partition/:style.:extension',
    url: '/images/:class/:id_partition/:style.:extension',
    default_url: '/defaults/user.jpeg'
  }

  LESSON_IMAGE = {
    path: 'public/images/:class/:id_partition/:style.:extension',
    url: '/images/:class/:id_partition/:style.:extension',
    default_url: '/defaults/user.jpeg'
  }

  BANNER_IMAGE = {
    path: 'public/images/banner_images/:id_partition/:style.:extension',
    url: '/images/banner_images/:id_partition/:style.:extension'
  }
  STUDENTGALLERY_IMAGE = {
    path: 'public/images/:class/:id_partition/:style.:extension',
    url: '/images/:class/:id_partition/:style.:extension'
  }

end


class TciWorkshopPhoto
  def self.worshop_photo_credential i
    if Rails.application.config.s3_configuration
      return S3_CREDENTIALS.merge({
      path: "/:class/:id_partition/#{i}/:style.:extension",
      default_url: '/images/defaults/:class/:style.gif'
    })
    else
      return {
        path: "public/images/:class/:id_partition/#{i}/:style.:extension",
        url: "/images/:class/:id_partition/#{i}/:style.:extension",
        default_url: '/images/defaults/user.jpeg'
      }
    end
  end
end
