class Attachment < ActiveRecord::Base

  STATUSES = { pending: 'n', processing: 'p', completed: 'c', error: 'e' }

  belongs_to :owner, foreign_key: :owner_user_id, class_name: :User
  belongs_to :attachable, polymorphic: true

  acts_as_deletable
  acts_as_critiqueable

  has_attached_file :asset,
                    ASSETS_FILES.merge({styles: { small: [ '35x35#', :png ],
                      medium: [ '75x75#', :png ], large: [ '115x115#', :png ],
                      detail: { geometry: Proc.new { |a| a.send(:geometry_string_with_orientation, 675, 555) }, format: :png },
                      w360xh270: { geometry: Proc.new { |a| a.send(:geometry_string_with_orientation, 360, 270) }, format: :png },
                      w480xh360: { geometry: Proc.new { |a| a.send(:geometry_string_with_orientation, 480, 360) }, format: :png },
                      in_lesson: { geometry: Proc.new { |a| a.send(:geometry_string_with_orientation, 620, 450) }, format: :png },
                      w660xh230: [ '660x230#', :png], w660xh440: [ '660x440#', :png],
                      w53xh53: [ '53x53#', :png ], w60xh60: [ '60x60#', :png ] },
                      :default_url => "/images/sample_video_icon.png",
                    processors: Proc.new{ |a| if a.video? then [ :video_thumbnail ] elsif a.audio? then [ :audio_thumbnail ] elsif a.image? then [ :thumbnail ] end }})

  validates_attachment_content_type :asset,
    content_type: config.paperclip.image_content_types + config.paperclip.audio_content_types + config.paperclip.video_content_types

  before_asset_post_process :set_asset_orientation

  attr_accessible :title, :description, :position, :meta_data, :attachable_id, :attachable_type, :asset, :youtube_video_id, :vimeo_video_id, :owner_user_id

  validates_presence_of :owner_user_id, :attachable_id, :attachable_type
  validates_existence_of :owner, :attachable, allow_nil: true

  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :description, maximum: 16777215
  end

  with_options only_integer: true do |o|
    o.validates_numericality_of :position, :greater_than_or_equal_to => 0
  end


  #validates_attachment_presence :asset, message: 'file cant blank', on: :create
  #validates_attachment_presence :asset, message: 'file cant blank'
  validates_attachment_presence :asset, less_than: config.attachment.maximum_asset_size, if: :asset_size
  validates_inclusion_of :status, in: STATUSES.keys

  validate :must_be_attachable_attachable, on: :create
  validate :validation_on_video_or_image, :valid_video_url

  # Must define before has_attached_file to prevent Paperclip callback running first.
  before_destroy :queue_transcoded_file_for_delete
  before_create :set_initial_status
  before_save :check_image_present

  after_create :send_mail_to_instructor, Proc.new{|attachment| attachment.attachable_type == "AssignmentSubmission"}

  delegate :url, :path, :to => :asset

  def s3_url(style = nil, expires_in = 1.hour)
    if Rails.application.config.s3_configuration
      AWS::S3::S3Object.url_for(path(style || asset.default_style), asset.bucket_name, :expires_in => expires_in, :use_ssl => asset.s3_protocol == 'https')
    else
      asset.url(style)
    end
  end

  def self.reset_error_status
    non_deleted.error.update_all( { status: STATUSES[:pending] })
  end

  def status
    value = read_attribute(:status)
    STATUSES.has_value?(value) ? STATUSES.invert[value] : value
  end

  def status=(value)
    write_attribute(:status, value.respond_to?(:to_sym) && !value.blank? && STATUSES.has_key?(value.to_sym) ? STATUSES[value.to_sym] : value)
  end

  def asset_size
    return if asset.present?
  end

  STATUSES.each do |key, value|
    scope(key, -> { where(status: value)} )
    define_method("#{key}?") { status == key }
    define_method("#{key}!") { update_attribute(:status, STATUSES[key]) }
  end

  def audio?
    config.paperclip.audio_content_types.include?(asset.content_type.to_s.downcase)
  end

  def image?
    config.paperclip.image_content_types.include?(asset.content_type.to_s.downcase)
  end

  def video?
    config.paperclip.video_content_types.include?(asset.content_type.to_s.downcase)
  end

  def editable?(user)
    owner == user
  end

  def readable?(user)
    attachable.respond_to?(:readable?) ? attachable.readable?(user) : true
  end

  def orientation
    asset.instance_read(:orientation) unless asset.nil?
  end

  #def critiqueable?(user)
  #  !deleted? && attachable.is_a?(AssignmentSubmission)
  #end

  def transcode!
    raise PaperclipError, 'The attachment is not a video' unless video?
    original_file = Paperclip.io_adapters.for(asset)
    asset.queued_for_write[:transcoded] = Paperclip.processor(:video_transcode).make(original_file, { :whiny => true, :geometry => '480x360' }, asset)
    asset.save
  ensure
    original_file.close if original_file.respond_to?(:close)
  end

  # This method send mail to all instructor that attachment has beed changed.
  def send_mail_to_instructor
    AssignmentSubmissionMailer.attachment_changed_notification(self.attachable).deliver
  end

  protected

    def must_be_attachable_attachable
      errors.add(:attachable, 'cannot be attached to') unless owner.nil? || !attachable.respond_to?(:attachable?) || attachable.attachable?(owner)
    end

    def set_initial_status
      self.status = (video? ? :pending : :completed)
      true
    end

    def queue_transcoded_file_for_delete
      # Again this smells but can't think of a better way yet
      asset.instance_variable_get(:@queued_for_delete) << asset.path(:transcoded) if asset.exists?(:transcoded)
    end

    def queue_transcoded_file_for_delete_and_flag_as_pending
      if video?
        queue_transcoded_file_for_delete
        self.class.update_all({ :status => STATUSES[:pending] }, { :id => id })
      end
      true
    end

    def set_asset_orientation
      if asset.dirty?
        begin
          original_file = Paperclip.io_adapters.for(asset)
          geometry = (video? ? Paperclip::VideoGeometry : Paperclip::Geometry).from_file(original_file) rescue nil
          orientation = unless geometry.nil?
                          case
                            when geometry.square? then 'square'
                            when geometry.horizontal? then 'landscape'
                            when geometry.vertical? then 'portrait'
                          end
                        else
                          ''
                        end
          asset.instance_write(:orientation, orientation)
        #ensure
        #  original_file.close if original_file.respond_to?(:close)
        end
      end
      true
    end

    def geometry_string_with_orientation(width, height)
      geometry = (video? ? Paperclip::VideoGeometry : Paperclip::Geometry).from_file(asset.path) rescue nil

      case
        when !geometry.nil? && geometry.horizontal? then "#{width}x#{(width / geometry.aspect).to_i}>"
        when !geometry.nil? && geometry.vertical? then "#{(height / geometry.aspect).to_i}x#{height}>"
      else
        "#{width}x#{height}>"
      end
    end

    def validation_on_video_or_image
      if youtube_video_id.present?
        return true
      elsif vimeo_video_id.present?
        return true
      elsif asset.present?
        return true
      else
        errors[:base] << "Fill video Id or Upload Image"
      end
    end

    def check_image_present
        if youtube_video_id.present?
          self.asset = open("http://img.youtube.com/vi/#{youtube_video_id}/0.jpg")
        elsif vimeo_video_id.present?
          begin
            ans = JSON.parse(open("http://vimeo.com/api/v2/video/#{vimeo_video_id}.json").read)[0]['thumbnail_large']
            self.asset = open(ans)

          rescue Exception => e
          end
        elsif asset.present?
          self.asset = asset
        else
          ''
        end
    end

    def valid_video_url
      if youtube_video_id.present?
        uri = valid_video_url_checker("http://gdata.youtube.com/feeds/api/videos/#{youtube_video_id}")
        uri == "200" ? true : errors.add(:youtube_video_id, 'invalid youtube id')
      elsif vimeo_video_id.present?
        uri = valid_vimeo_url_checker("https://vimeo.com/api/oembed.json?url=https%3A//vimeo.com/#{vimeo_video_id}")
        uri == "200" ? true : errors.add(:vimeo_video_id, 'invalid vimeo id')
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

