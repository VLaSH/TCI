class Administrator::ForumTopicsController < Administrator::BaseController

  include Theia::ActsAsDiscussable::Controller

  before_filter :find_discussable, :only => [ :index, :new, :create ]
  before_filter :find_forum_topic, :except => [ :index, :new, :create ]
  before_filter :require_edit_permission, :only => [ :edit, :update ]
  before_filter :require_delete_permission, :only => [ :delete, :destroy ]

  def index
    @forum_topics = (@discussable.nil? ? ForumTopic.non_deleted.general_discussion : @discussable.forum_topics).paginate(:page => params[:page], :order => "#{ForumTopic.quoted_column_name('publish_on')} DESC")
  end

  def show
  end

  def new
    @forum_topic = build_forum_topic
  end

  def create
    @forum_topic = build_forum_topic(params[:forum_topic])

    if @forum_topic.save
      flash_and_redirect_to('Your forum topic has been created successfully', :notice, administrator_forum_topic_path(@forum_topic))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @forum_topic.update_attributes(params[:forum_topic])
      flash_and_redirect_to('Your forum topic has been updated successfully', :notice, administrator_forum_topic_path(@forum_topic))
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @forum_topic.delete!
      flash_and_redirect_to('Your forum topic has been deleted successfully', :notice, administrator_forum_topics_path)
    else
      render(:action => 'delete')
    end
  end

  protected

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the topic', :error, administrator_forum_topic_path(@forum_topic)) unless @forum_topic.editable?(current_user)
    end

    def require_delete_permission
      flash_and_redirect_to('You are not allowed to delete the topic', :error, administrator_forum_topic_path(@forum_topic)) unless @forum_topic.deletable?(current_user)
    end

end