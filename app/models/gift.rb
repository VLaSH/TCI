class Gift < ActiveRecord::Base
  self.per_page = 20

  CATEGORIES = {
    '1' => 'Course',
    '3' => 'Review',
    '4' => 'One-to-One mentorship',
  }

  attr_accessor :price

  acts_as_money

  validates :lessons_amount, :price_in_cents, :title, presence: true
  validate :custom_categories, on: :create

  money :price, currency: false, cents: :price_in_cents

  before_create :convert_to_cents

  has_many :user_gifts
  has_many :users, through: :user_gifts
  belongs_to :course

  def self.find_by_category_and_lessons_amount(course_id, lessons_amount)
    course = Course.find_by(id: course_id)
    return nil if course.nil?

    if course.category_4
      find_by(category: 4)
    elsif course.category_3
      course.gift
    else
      find_by(category: 1, lessons_amount: lessons_amount)
    end
  end

  private

  def convert_to_cents
    self.price_in_cents = price * 100
  end

  def custom_categories
    if [3, 4].include?(category) && Gift.exists?(["category = ?", category])
      errors.add(:category, 'Review or one-to-one mentorship already exists')
    end
  end
end
