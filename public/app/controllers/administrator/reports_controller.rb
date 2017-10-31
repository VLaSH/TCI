class Administrator::ReportsController < Administrator::BaseController

  before_action :find_instructors

  # GET administrator/reports/new
  def new

  end

  # POST administrator/reports
  def create
    instructor = @instructors.where(id: params[:instructor_id]).first
    respond_to do |format|
      if instructor
        data = instructor.generate_report(params[:date])
        format.xlsx do
          if data
            send_data data.to_stream.read, type: "application/xlsx", filename: "#{instructor.full_name} - Report #{Date::MONTHNAMES[params[:date][:month].to_i]}-#{params[:date][:year]}.xlsx"
          else
            redirect_to new_administrator_report_path, alert: 'Sorry! No date present for selected month.'
          end
        end
      else
        redirect_to student_root_path, alert: 'Please, Select instructor for Report.'
      end
    end
  end

  private

    # set all instructors
    def find_instructors
      @instructors = Instructor.all
    end

    # setup the page for reports
    def setup_page
      page_config do |page|
        super
        page.secondary_navigation_section = :reports
        page.title.unshift('Reports')
      end
    end

end
