json.array!(@administrator_testimonials) do |administrator_testimonial|
  json.extract! administrator_testimonial, :id, :title, :content, :logo
  json.url administrator_testimonial_url(administrator_testimonial, format: :json)
end
