class Administrator::UsersController < Administrator::BaseController

  before_filter :find_user, :except => [ :index, :new, :create, :export ]
  helper :users

  def index
    @show_administrators = params.has_key?(:administrator) && !params[:administrator].blank? && params[:administrator].to_i == 1 ? true : false
    @show_instructors = params.has_key?(:instructor) && !params[:instructor].blank? && params[:instructor].to_i == 1 ? true : false
    @show_students = params.has_key?(:student) && !params[:student].blank? && params[:student].to_i == 1 ? true : false
    @search = params.has_key?(:search) && !params[:search].blank? ? params[:search] : nil

    @conditions = ""
    if (@show_administrators == false) && (@show_instructors == false) && (@show_students == false)
      @show_administrators = true
      @show_instructors = true
      @show_students = true
    else
      @conditions = []
      @conditions << "users.role = 'a'" if @show_administrators
      @conditions << "users.role = 'i'" if @show_instructors
      @conditions << "users.role = 's'" if @show_students
      @conditions = @conditions.join(' OR ')
      @conditions = "(#{@conditions})"
    end
    unless @search.nil?
      @search_sql = "(users.given_name like '%#{@search}%' OR users.family_name like '%#{@search}%' OR users.email like '%#{@search}%')"
      @conditions = "#{@conditions} AND #{@search_sql}"
    end

    @users = User.paginate(:page => params[:page], :order => 'role ASC, family_name ASC, given_name ASC', :conditions => @conditions)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])

    if @user.send(save_method) == true
      flash_and_redirect_to('You have successfully created a new user account', :notice, administrator_users_path)
    else
      render(:action => 'new')
    end
  end

  def edit
  end

  def update
    @user.attributes = params[:user].except(:role, :status)
    @user.role = params[:user][:role]

    if @user.send(save_method) == true
      flash_and_redirect_to('You have successfully updated the user account', :notice, administrator_users_path)
    else
      render(:action => 'edit')
    end
  end

  def delete
  end

  def destroy
    if @user.destroy
      flash_and_redirect_to('Your user has been deleted successfully', :notice, administrator_users_path)
    else
      render(:action => 'delete')
    end
  end

  def export
    csv_string = CSV.generate do |csv|
      cols = ["email", "given_name", "family_name"]
      csv << cols
      User.find_all_by_role('s').each do |entry|
        csv << [entry.email, entry.given_name, entry.family_name]
      end
    end

    filename = "users-#{Time.now.to_date.to_s}.csv"

    respond_to do |format|
      format.csv { send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => filename) }
    end
  end

  protected

    def find_user
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash_and_redirect_to('The requested user account does not exist', :error, administrator_users_path)
    end

    def save_method
      case params[:user][:status]
        when 'activated' then @user.activated? ? :save : (@user.disabled? ? :enable! : :activate!)
        when 'disabled' then @user.disabled? ? :save : :disable!
        when 'pending' then @user.pending? ? :save : :register!
      else
        :save
      end
    end

    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :users
        page.title.unshift('Users')
      end
    end

end
