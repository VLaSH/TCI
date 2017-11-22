class Instructor::LessonsCommentController < Instructor::BaseController

 
  def delete
  	#@topic_id = {params[:topic_id]}
     @data = ActiveRecord::Base.connection.execute("update forum_topics set posts_count=posts_count-1 where id=#{params[:topic_id]}")
     @data = ActiveRecord::Base.connection.execute("delete from forum_posts where id=#{params[:id]}")
      respond_to do |format|
		msg = { :status => "ok", :message => "Success!", :html => "<b>...</b>" }
		format.json  { render :json => msg } # don't do msg.to_json
	  end
  end
end
