class AttachmentsController < ApplicationController

  def download
    head(:not_found) and return if (attachment = Attachment.find_by_id(params[:id])).nil?

    style = params[:style] || :original
    
    redirect_to(attachment.s3_url(style))
  end

end