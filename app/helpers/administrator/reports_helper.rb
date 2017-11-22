module Administrator::ReportsHelper
  # Returs month with number for select method.
  def month_list
    months = []
    Date::MONTHNAMES.compact.each_with_index{ |month, index| months << [month, index + 1] }
    months
  end
end
