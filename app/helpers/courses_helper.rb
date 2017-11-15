module CoursesHelper
  def course_hero(course)
    content_tag(
      :div,
      [
        link_to(image_tag(course.thumbnail_url), course_path(course)),
        content_tag(:p, content_tag(:span, link_to(course.title, "#")))
      ].join,
      :class => "thumbnail last course-hero"
    )
  end

  def delete_review(review)
    link_to (image_tag 'icons/delete.png') , [:student, @course, review], method: :delete, data: {confirm: 'Are you sure?' }, class: 'pull-right', title: 'Delete' if review.can_delete?(current_user)
  end

  # This method created the course Enroll button/ renew button.
  def course_enrolment_btn
    if !(current_user && @course.existing_enrolment(current_user)) && !@course.has_lessons?
      link_to 'Enroll in this Course', courses_path, onclick: "alert('Sorry! This course is not ready for enrollment ');"
    elsif !(current_user && @course.existing_enrolment(current_user))
      link_to 'Enroll on this Course', new_course_purchase_path(@course), { class: 'buy-course-link', data: { link: new_course_purchase_path(@course) } }
    elsif @course.existing_enrolment(current_user).renewable?(current_user)
      link_to 'Renew on this Course', renew_course_purchase_path(@course)
    end
  end

  def converted_price(price, currency)
    Money.new(price, 'USD').exchange_to(currency.present? ? currency.to_sym : :USD)
  end
  # create a instructors block image. if instructors images are not set then added default.
  def instructor_block_image
    unless @course.instructors.size.zero?
      link_to(image_tag(user_photo_path(:id => @course.instructors.first, :style => :w240xh230), :alt => @course.instructors.first.full_name), instructor_path(@course.instructors.first), class: 'profile_block')
    else
      image_tag 'defaults/user.jpg'
     end
  end

  # This method returns instructors names with links.
  def instructors_names
    names = ''
    if @course.instructors.blank?
      names += 'No Assigned yet.'
    else
      @course.instructors.each do |instructor|
        names += (link_to instructor.full_name, instructor_path(instructor))
      end
    end
    names.html_safe
  end

  # This Code Use in Home Page for Banner Images.
  def home_banner_images
    HomeBanner.all
  end

  # This Code Use in Workshop page Banner Images.
  def workshop_banner_image
    WorkshopBanner.first.image_s3_url(:w947xh469) unless WorkshopBanner.all.blank?
  end

  # This Code Use in mentorship page Banner Images.
  def mentorship_banner_image
    MentorshipBanner.first.image_s3_url(:w947xh469) unless  MentorshipBanner.all.blank?
  end

  # This Code Use in How it work page Banner Images.
  def how_it_work_banner_image
    HowItWorkBanner.first.image_s3_url(:w947xh469) unless HowItWorkBanner.all.blank?
  end

  # This Code Use in Course page Banner Images.
  def photography_course_banner_image
    CoursePhotographyBanner.first.image_s3_url unless CoursePhotographyBanner.all.blank?
  end

  # This Code Use in Course page Banner Images.
  def multimedia_course_banner_image
    CourseMultimediaBanner.first.image_s3_url unless CourseMultimediaBanner.all.blank?
  end

  # This Code Use in Portfolio page Banner Images.
  def portfolio_banner_image
    PortfolioBanner.first.image_s3_url(:w947xh469) unless PortfolioBanner.all.blank?
  end

  # This Code Use in Home Page course grid section
  def course_grid_section
    CourseGridSection.first.image_s3_url(:w316xh179) unless CourseGridSection.all.blank?
  end

  # This Code Use in Home Page portfolio grid section
  def portfolio_grid_section
    PortfolioGridSection.first.image_s3_url(:w316xh179) unless PortfolioGridSection.all.blank?
  end

  # This Code Use in Home Page mentorship grid section
  def mentorship_grid_section
    MentorshipGridSection.first.image_s3_url(:w316xh179) unless MentorshipGridSection.all.blank?
  end

  # This Code Use in Home Page mentorship grid section
  def student_gallery_grid_section
    StudentGalleryGridSection.first.image_s3_url(:w316xh179) unless StudentGalleryGridSection.all.blank?
  end

  # This Code Use in Home Page mentorship grid section
  def whats_new_grid_section
    WhatsNewGridSection.first.image_s3_url(:w316xh179) unless WhatsNewGridSection.all.blank?
  end

  # This Code Use in Home Page mentorship grid section
  def tci_blog_grid_section
    TciBlogGridSection.first.image_s3_url(:w316xh179) unless TciBlogGridSection.all.blank?
  end

  #This Code use for find free course
  def free_course
    sample_course = Settings.find_by_key('sample course')
    course = Course.find_by_id(sample_course.value)
    if sample_course && sample_course.value.present? && course
      course_path(course)
    elsif first_free_course
      course_path(first_free_course)
    else
      'javascript:void(0);'
    end
  end





  # find first created free course
  def first_free_course
    Course.visible.available.free.first
  end

  # course skill lavel
  def course_skil_level(course)
    skill = ''
    skill << 'Beginner' if course.category_1

    if course.category_2  && course.category_1
      skill << ', Intermediate'
    elsif course.category_2
      skill << 'Intermediate'
    else
    end

    if (course.category_1 || course.category_2 ) && course.category_5
      skill << ', Advance'
    elsif course.category_5
      skill << 'Advance'
    else
    end
    if skill.blank?
      skill << 'Any One'
    else
    skill
    end
  end

  # course type name display on course listing place

  def get_course_type(course)
    course.course_type.present? ? course.course_type.title : ''
  end
end
