class Student::ForumPostsController < Student::BaseController

  include Theia::ActsAsDiscussable::Controller

  before_filter :find_forum_topic, :only => [ :new, :create ]
  before_filter :find_forum_post, :require_edit_permission, :only => [ :edit, :update ]

  def new
    @forum_post = build_forum_post
  end

  def create
    redirect = (params[:forum_post].has_key?(:redirect) ? params[:forum_post][:redirect] : nil) if params.has_key?(:forum_post)
    @forum_post = build_forum_post(params[:forum_post])

    if @forum_post.save
      @forum_post.attachments << Attachment.create(asset: params[:forum_post][:file], owner_user_id: current_user.id)
      flash_and_redirect_to('Your forum post has been created successfully', :notice, redirect.nil? ? student_forum_topic_path(@forum_post.topic) : redirect)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @forum_post.update_attributes(params[:forum_post])
      flash_and_redirect_to('Your forum post has been updated successfully', :notice, student_forum_topic_path(@forum_post.topic))
    else
      render(:action => 'edit')
    end
  end

  protected

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the post', :error, student_forum_topic_path(@forum_post.topic)) unless @forum_post.editable?(current_user)
    end

end