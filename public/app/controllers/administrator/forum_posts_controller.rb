class Administrator::ForumPostsController < Administrator::BaseController

  include Theia::ActsAsDiscussable::Controller

  before_filter :find_forum_topic, :only => [ :new, :create ]
  before_filter :find_forum_post, :only => [ :edit, :update, :delete, :destroy ]
  before_filter :require_edit_permission, :only => [ :edit, :update ]
  before_filter :require_delete_permission, :only => [ :delete, :destroy ]

  def new
    @forum_post = build_forum_post
  end

  def create
    @forum_post = build_forum_post(params[:forum_post])

    if @forum_post.save
      flash_and_redirect_to('Your forum post has been created successfully', :notice, administrator_forum_topic_path(@forum_post.topic))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @forum_post.update_attributes(params[:forum_post])
      flash_and_redirect_to('Your forum post has been updated successfully', :notice, administrator_forum_topic_path(@forum_post.topic))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @forum_post.delete!
      flash_and_redirect_to('Your forum post has been deleted successfully', :notice, administrator_forum_topic_path(@forum_post.topic))
    else
      render(:action => 'delete')
    end
  end

  protected

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the post', :error, administrator_forum_topic_path(@forum_post.topic)) unless @forum_post.editable?(current_user)
    end

    def require_delete_permission
      flash_and_redirect_to('You are not allowed to delete the post', :error, administrator_forum_topic_path(@forum_post.topic)) unless @forum_post.deletable?(current_user)
    end

end