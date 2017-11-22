class Renewal < ActiveRecord::Base

  acts_as_money

  belongs_to :course

  validates_presence_of :duration

  money :price, currency: :price_currency, cents: :price_in_cents

  attr_accessible :duration, :amount, :price, :price_in_cents

end
