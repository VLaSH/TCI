class ContestsController < ApplicationController
	def index
	    @contests = Contest.page(params[:page]).order('id DESC')

	    @cd = ContestDescription.find(:last)
  	end
end
