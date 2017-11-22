class Settings < ActiveRecord::Base

  attr_accessible :key, :value, :method, :other

  # after_find do |s|
  #   s.value = s.value.send(s.method)
  # end
  validate :validate_on_video_url

  def validate_on_video_url
    if key == 'video_url'
      if value.present? && method.blank?
        errors.add(:method, '')
      else
        valid_video_url
      end
    end
  end

  def valid_video_url
      if method == '2'
        uri = valid_video_url_checker("http://gdata.youtube.com/feeds/api/videos/#{value}")
        uri == "200" ? true : errors.add(:value, 'invalid youtube id')
      elsif method == '1'
        uri = valid_vimeo_url_checker("https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/#{value}")
        uri == "200" ? true : errors.add(:value, 'invalid vimeo id')
      else
        true
      end
    end

    def valid_video_url_checker(url)
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.code
    end

    def valid_vimeo_url_checker(url)
      begin
        status = open(url).status[0]
      rescue Exception => e
        status = "404"
      end
    end

end
