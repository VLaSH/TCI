class Student::ForumTopicsController < Student::BaseController

  include Theia::ActsAsDiscussable::Controller

  before_filter :find_discussable, :only => [ :index, :new, :create ]
  before_filter :find_forum_topic, :except => [ :index, :new, :create ]
  before_filter :require_edit_permission, :only => [ :edit, :update ]

  def index
    #@forum_topics = (@discussable.nil? ? ForumTopic.non_deleted.general_discussion : @discussable.forum_topics).paginate(:page => params[:page], :order => "#{ForumTopic.quoted_column_name('publish_on')} DESC")
    @course_discussion = ForumTopic.published.course_discussion_for_student(current_user).all
    @general_discussion = ForumTopic.published.general_discussion.all
  end

  def show
    unless @forum_topic.nil?
      @forum_post = build_forum_post
    end
  end

  def new
    @forum_topic = build_forum_topic
  end

  def create
    @forum_topic = build_forum_topic(params[:forum_topic])

    if @forum_topic.save
      flash_and_redirect_to('Your forum topic has been created successfully', :notice, student_forum_topic_path(@forum_topic))
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    if @forum_topic.update_attributes(params[:forum_topic])
      flash_and_redirect_to('Your forum topic has been updated successfully', :notice, student_forum_topic_path(@forum_topic))
    else
      render(:action => 'edit')
    end
  end

  protected

    def require_edit_permission
      flash_and_redirect_to('You are not allowed to edit the topic', :error, student_forum_topic_path(@forum_topic)) unless @forum_topic.editable?(current_user)
    end
    
    def setup_page
      super
      page_config do |page|
        page.body_tag_options[:class] = 'student'
        page.body_tag_options[:id] = 'forumtopics'
        page.secondary_navigation_section = :forums
        page.secondary_navigation = true
        page.title.unshift('Forums')
      end
    end

end