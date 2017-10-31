class Lesson < ActiveRecord::Base

  belongs_to :course

  with_options dependent: :destroy do |o|
    o.has_many :assignments, -> { where(:deleted_at => nil) }
    o.has_many :deleted_assignments, -> { where("deleted_at IS NOT NULL") }, class_name: 'Assignment'
  end

  with_options dependent: :destroy do |o|
    o.has_many :scheduled_lessons, -> { where(:deleted_at => nil) }
    o.has_many :deleted_scheduled_lessons, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL") }, class_name: :ScheduledLesson
  end

  acts_as_attachable
  acts_as_deletable

  has_attached_file :photo, LESSON_IMAGE.merge(styles: { :small  => '35x35#',
   :medium => '75x75#',
   :large  => '115x115#',
   :hero   => '195x195#' })

  has_deletable_attachment :photo

  attr_accessible :title, :summary, :description, :duration, :position, :photo, :vimeo_asset, :delete_vimeo

  validates_presence_of :title

  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :summary, maximum: 65535
    o.validates_length_of :description, maximum: 16777215
  end

  with_options only_integer: true do |o|
    o.validates_numericality_of :position, greater_than_or_equal_to: 0
  end

  validates_attachment_content_type :photo, content_type: config.paperclip.image_content_types
  validates_attachment_size :photo, less_than: config.lesson.maximum_photo_size

  # validate_on_create :course_must_not_be_deleted
  validate :course_must_not_be_deleted, :on => :create
  # validate :position_must_be_unique
  validates_uniqueness_of :position, scope: [:course_id]
  validate :valid_video_url

  default_scope { order('position ASC') }

  # This photo_s3_url function call with lesson and use with new and edit image
  # If condition work in production mode and else condition work in development mode
  def photo_s3_url(style=nil, expires_in=1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(photo.path(style || photo.default_style), photo.bucket_name, expires_in: expires_in, use_ssl: photo.s3_protocol == 'https')
    else
      photo.url(style)
    end
  end

  def active?
    !deleted?
  end


  def attachable?(user)
    !deleted? && course.attachable?(user)
  end

 # vimeo attachment
  def valid_video_url
    if !vimeo_asset.blank? && (vimeo_asset =~ /\A\d+\z/ ? false : true)
          file_temp_path =vimeo_asset.path
#          abort(file_temp_path)
          auth = "Bearer 298eef37c0d2639ea331762ae4e35e60"
          resp = HTTParty.post "https://api.vimeo.com/me/videos", headers: { "Authorization" => auth, "Accept" => "application/vnd.vimeo.*+json;version=3.2" }, body: { type: "streaming"}
          ticket = JSON.parse(resp.body)
          target = ticket["upload_link"]
          size =vimeo_asset.size 
         # abort(size.to_s)
          last_byte = 0
          File.open(file_temp_path, "rb") do |f|
              uri = URI(target)
                  while last_byte < size do
                      req = Net::HTTP::Put.new("#{uri.path}?#{uri.query}", initheader = { "Authorization" => auth, "Content-Length" => size.to_s,"Content-Range" => "bytes: #{last_byte}-#{size}/#{size}","title"=>"new"} )
                      req.body = f.read
                  begin
                       response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
                  rescue Errno::EPIPE
                    puts "error'd"
                  end
                  progress_resp = HTTParty.put target, headers: { "Content-Range" => 'bytes */*', "Authorization" => auth}
                  last_byte = progress_resp.headers["range"].split("-").last.to_i
                  puts last_byte
                end
            end
            resp = HTTParty.delete "https://api.vimeo.com#{ticket["complete_uri"]}", headers: { "Authorization" => auth }
           
            uri = URI.parse('https://api.vimeo.com/me/videos')
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true
            request = Net::HTTP::Get.new(uri.request_uri,"Authorization" =>auth)
            response = http.request(request)
            response = JSON.parse(response.body)
            splitresponse = response['data'][0]['uri'].split('/')
            vimeoId =splitresponse[2].to_s
            self.vimeo_asset = vimeoId
            self.delete_vimeo =0
            uri = valid_vimeo_url_checker("https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/#{vimeoId}")
            uri == "200" ? true : errors.add(:vimeo_asset, 'video uploading problem on vimeo.')
      else
        true
      end
    end
    
   def valid_vimeo_url_checker(url)
      begin
        status = open(url).status[0]
      rescue Exception => e
        status = "404"
      end
    end 
    
   def self.get_thumbnail(vimeoId)
     url_build ="https://vimeo.com/api/v2/video/#{vimeoId}.json"
     #abort(url_build)
     ans = JSON.parse(open(url_build).read)[0]['thumbnail_small']
   end
  protected

    def course_must_not_be_deleted
      errors.add(:course, 'must not be deleted') unless course.nil? || !course.deleted?
    end
end
