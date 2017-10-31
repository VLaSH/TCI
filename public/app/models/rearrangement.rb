class Rearrangement < ActiveRecord::Base
  belongs_to :assignment

  delegate :lesson, to: :assignment
  delegate :course, to: :lesson

  acts_as_attachable
  acts_as_deletable

  attr_accessible :title, :summary
  validates_presence_of :title
  with_options allow_blank: true do |o|
    o.validates_length_of :title, maximum: 255
    o.validates_length_of :summary, maximum: 65535
  end

  def attachable?(user)
    !deleted? && lesson.attachable?(user)
  end
end
