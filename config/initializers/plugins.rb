# Set the default currency and exchange rate bank
#require 'money/rails'
Money.default_currency = 'USD'
#Money.bank = ExchangeRate

# Initialise the pagination renderer
WillPaginate::ViewHelpers.pagination_options[:renderer] = 'TheWebFellas::PaginationLinkRenderer'
WillPaginate::ViewHelpers.pagination_options[:separator] = "\n"
WillPaginate::ViewHelpers.pagination_options[:first_label] = 'First'
WillPaginate::ViewHelpers.pagination_options[:previous_label] = 'Previous'
WillPaginate::ViewHelpers.pagination_options[:next_label] = 'Next'
WillPaginate::ViewHelpers.pagination_options[:last_label] = 'Last'
WillPaginate::ViewHelpers.pagination_options[:inner_window] = 5

Paperclip.options[:whiny] = true
Paperclip.options[:swallow_stderr] = false
# Add content type sensitive file extension interpolation for Paperclip
Paperclip.interpolates :content_type_extension do |attachment, style_name|
  style_name ||= :original
  case
    when attachment.instance.video? && style_name.to_s == 'transcoded' then
      'flv'
    when attachment.instance.video? && style_name.to_s != 'original' then
      'png'
    when ((style = attachment.styles[style_name.to_sym]) && !style[:format].blank?) then
      style[:format]
  else
    File.extname(attachment.original_filename).gsub(/^\.+/, "")
  end
end
