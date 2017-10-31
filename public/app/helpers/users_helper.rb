module UsersHelper

  def user_full_name(user)
    user.full_name
  end

  def user_address_country_name(user)
    CountryCodes.find_by_a2(user.address_country)[:name]
  end

  def user_humanize_role_name(role)
    role.to_s.titleize
  end
  
  def user_given_name_owns(user)
    [ user.given_name, "'s" ].join
  end
  
  def profile_with_ellipsis(user, length = 30)
    truncate_html(user.profile, 30, "&hellip;")
  end

end