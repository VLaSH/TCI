class BlogPost < ActiveRecord::Base
  scope :latest, -> { order("created_at DESC").limit(4) }

  class << self
  	def all(*args)
  		super(*args).order('created_at DESC')
  	end
  end
end