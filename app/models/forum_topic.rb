class ForumTopic < ActiveRecord::Base

  VALID_DISCUSSABLE_TYPES = %w(Course ScheduledLesson ScheduledAssignment)

  belongs_to :user
  belongs_to :discussable, polymorphic: true

  with_options class_name: :ForumPost, dependent: :destroy do |o|
    o.has_many :posts, -> { where deleted_at: nil }
    o.has_many :deleted_posts, -> { where "#{quoted_column_name('deleted_at')} IS NOT NULL" }
  end

  has_many :forum_topic_users, dependent: :destroy
  has_many :all_forum_topic_users, through: :forum_topic_users, class_name: :User, source: :user

  acts_as_deletable

  attr_accessible :title, :content

  validates_presence_of :user_id, :title, :content
  validates_existence_of :user, :discussable, allow_nil: true

  with_options allow_blank: true do |o|
    #o.validates_inclusion_of :discussable_type, in: VALID_DISCUSSABLE_TYPES, message: "must be one of: #{VALID_DISCUSSABLE_TYPES.map { |t| t.constantize.human_name }.to_sentence(connector: 'or', skip_last_comma: true)}"
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :content, maximum: 16777215
  end

  validate :user_must_be_activated, :discussable_must_be_discussable, on: :create

  scope :general_discussion, -> { where(:discussable_id => nil, :discussable_type => nil) }

  scope :published, -> { where("#{ForumTopic.quoted_table_name}.#{quoted_column_name('deleted_at')} IS NULL AND (#{ForumTopic.quoted_table_name}.#{quoted_column_name('publish_on')} IS NULL OR #{ForumTopic.quoted_table_name}.#{quoted_column_name('publish_on')} <= ?)", Time.now) }

  scope :discussion_for_student, ->(user){
    joins(:forum_topic_users).
    where("#{ForumTopic.quoted_table_name}.discussable_type IS NULL OR (#{ForumTopicUser.quoted_table_name}.user_id = ? and #{ForumTopic.quoted_table_name}.deleted_at is null)", user.id).
    order('forum_topics.publish_on DESC') }

  scope :course_discussion_for_student, ->(user){
    joins(:forum_topic_users).
    where("(#{ForumTopicUser.quoted_table_name}.user_id = ? and #{ForumTopicUser.quoted_table_name}.deleted_at is null)", user.id).
    order('forum_topics.publish_on DESC') }

  # TODO - This can be removed after testing as we have default '.limit' method
  #scope :limit, ->(num) { limit(num) }

  before_save :set_publish_on

  def readable?(user)
    discussable.course && !deleted? && (!discussable.respond_to?(:discussable?) || discussable.discussable?(user))
  end

  def editable?(user)
    !user.nil? && (user.administrator? || self.user == user) && (!discussable.respond_to?(:discussable?) || discussable.discussable?(user))
  end

  def deletable?(user)
    !user.nil? && user.administrator?
  end

  protected

    def set_publish_on
      self.publish_on = Time.now
    end

    def user_must_be_activated
      errors.add(:user, 'must be activated') unless user.nil? || user.activated?
    end

    def discussable_must_be_discussable
      errors.add(:discussable, 'cannot be discussed') unless user.nil? || !discussable.respond_to?(:discussable?) || discussable.discussable?(user)
    end

end
