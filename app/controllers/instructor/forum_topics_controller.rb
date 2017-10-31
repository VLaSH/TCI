class Instructor::ForumTopicsController < Instructor::BaseController

  include Theia::ActsAsDiscussable::Controller

  before_filter :find_discussable, :only => [ :index, :new, :create ]
  before_filter :find_forum_topic, :except => [ :index, :new, :create ]
  before_filter :require_edit_permission, :only => [ :edit, :update ]

  def index
    @forum_topics = (@discussable.nil? ? ForumTopic.non_deleted.published : @discussable.forum_topics.non_deleted.published) #.paginate(:page => params[:page], :order => "#{ForumTopic.quoted_column_name('publish_on')} DESC")
  end

  def show
  end

  def new
    @forum_topic = build_forum_topic
  end

  def create
    @forum_topic = build_forum_topic(params[:forum_topic])

    if @forum_topic.save
      flash_and_redirect_to('Your forum topic has been created successfully', :notice, instructor_forum_topic_path(@forum_topic))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @forum_topic.update_attributes(params[:forum_topic])
      flash_and_redirect_to('Your forum topic has been updated successfully', :notice, instructor_forum_topic_path(@forum_topic))
    else
      render(:action => 'edit')
    end
  end

  protected

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the topic', :error, instructor_forum_topic_path(@forum_topic)) unless @forum_topic.editable?(current_user)
    end

    def setup_page
      super
      page_config do |page|
        page.secondary_navigation_section = :forum
        page.title.unshift('Forum')
      end
    end

end