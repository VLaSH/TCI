class ForumPost < ActiveRecord::Base

  belongs_to :user
  belongs_to :topic, class_name: :ForumTopic, foreign_key: :forum_topic_id, counter_cache: :posts_count
  belongs_to :forum_topic

  acts_as_attachable
  acts_as_deletable

  attr_accessible :content, :file
  attr_accessor :file
  validates_presence_of :user_id, :forum_topic_id, :content
  validates_existence_of :user, :topic, allow_nil: true
  validates_length_of :content, maximum: 16777215, allow_blank: true

  validate :user_must_be_activated, :topic_must_be_readable, on: :create

  after_update :update_topic_posts_count_after_deleted_at_change

  delegate :discussable, to: :forum_topic, prefix: true, allow_nil: true

  def editable?(user)
    !user.nil? && (user.administrator? || self.user == user) && topic.readable?(user)
  end

  def deletable?(user)
    !user.nil? && user.administrator?
  end

  protected

    def user_must_be_activated
      errors.add(:user, 'must be activated') unless user.nil? || user.activated?
    end

    def topic_must_be_readable
      errors.add(:topic, 'cannot be read by you') unless user.nil? || topic.nil? || topic.readable?(user)
    end

    def update_topic_posts_count_after_deleted_at_change
      ForumTopic.send((deleted_at.nil? ? :increment_counter : :decrement_counter), :posts_count, forum_topic_id) if deleted_at_was_changed?
    end

end
