module RenewalsHelper
  # all renewal of any perticuler course
  def renewals
    @course.renewals
  end
 # create new renewal object and use view of index
  def renewal
    Renewal.new

  end
end
