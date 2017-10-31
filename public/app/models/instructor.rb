class Instructor < User

  self.table_name = :users

  default_scope { where(role: User::ROLES[:instructor])}

  attr_accessor :report_date_range

  # This method generate reports.
  def generate_report(date)
    date ||= {}
    set_date(date)
    report_data = student_enrolments.where(created_at: report_date_range)
    unless report_data.blank?
      return Axlsx::Package.new do |p|
        p.workbook.add_worksheet(:name => "Report") do |sheet|
          sheet.add_row [
            'Student Name',
            'Course Name',
            "Status (New Enrollment/Renewal)",
            'Fees'
          ]
          student_enrolments.where(created_at: report_date_range).each do |enrolment|
            sheet.add_row [
              enrolment.student.full_name,
              enrolment.course.title,
              enrolment.status,
              enrolment.fees.to_f
            ]
          end
        end
      end
    else
      return false
    end
  end

  private

    # set report date rage.
    def set_date(date)
      if date.keys.include?('month') && date.keys.include?('year')
        start_date = Date.parse("1-#{date['month']}-#{date['year']}") rescue nil
        self.report_date_range = (start_date..(start_date.try(:end_of_month)))
      end
    end

end
