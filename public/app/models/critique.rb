class Critique < ActiveRecord::Base

  VALID_CRITIQUEABLE_TYPES = %w(AssignmentSubmission Attachment)

  belongs_to :critiqueable, :polymorphic => true
  belongs_to :user

  acts_as_attachable
  acts_as_deletable

  attr_accessible :comment

  validates_presence_of :user_id, :critiqueable_id, :comment
  validates_inclusion_of :critiqueable_type, :in => VALID_CRITIQUEABLE_TYPES, :message => "must be one of: #{VALID_CRITIQUEABLE_TYPES.map { |t| t.underscore.humanize.titleize }.to_sentence(:words_connector => ', ', :two_words_connector => ' or ', :last_word_connector => ' or ')}"
  validates_existence_of :critiqueable, :user, :allow_nil => true
  validates_length_of :comment, :maximum => 16777215, :allow_blank => true

  validate :critiqueable_must_be_critiqueable, :user_must_be_activated, on: :create

  def owner?(user)
    self.user == user
  end

  def editable?(user)
    !user.nil? && (user.administrator? || owner?(user))
  end
  alias_method :attachable?, :editable?
  alias_method :deletable?, :editable?

  protected

    def critiqueable_must_be_critiqueable
      errors.add(:critiqueable, 'cannot be critiqued') unless user.nil? || !critiqueable.respond_to?(:critiqueable?) || critiqueable.critiqueable?(user)
    end

    def user_must_be_activated
      errors.add(:user, 'must be activated') unless user.nil? || user.activated?
    end

end