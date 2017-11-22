class Tag < ActiveRecord::Base
  def to_param
    "#{id}-#{name.downcase.gsub(/[\W!\-]+/, ' ').strip.gsub(/[–]/, '-').gsub(/\ +/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')}"
  end
end