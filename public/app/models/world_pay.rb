class WorldPay
  include ActiveModel::Validations

  CREDENTIALS = YAML.load_file("#{Rails.root}/config/world_pay.yml")[Rails.env].symbolize_keys
  URL = {
    test: 'https://secure-test.worldpay.com/jsp/merchant/xml/paymentService.jsp',
    live: 'https://secure.worldpay.com/jsp/merchant/xml/paymentService.jsp'
  }

  attr_accessor :merchant_code, :country_code, :amount, :first_name, :last_name, :address_1,
                :address_2, :address_3, :postal_code, :city, :country_code, :return_url, :currency,
                :email, :id, :state, :approve_url, :description, :order_id, :response

  validates_presence_of :amount, :address_1, :city, :country_code, :first_name, :last_name, :country_code, :return_url

  # initialize the worldpay details.
  def initialize(obj={})
    @merchant_code = CREDENTIALS[:merchant_code]
    @currency = CREDENTIALS[:currency]
    @amount = obj[:amount]
    @email = obj[:email]
    @first_name = obj[:first_name]
    @last_name = obj[:last_name]
    @address_1 = obj[:address_1]
    @address_2 = obj[:address_2]
    @address_3 = obj[:address_3]
    @postal_code = obj[:postal_code]
    @country_code = obj[:country_code]
    @order_id = obj[:order_id].blank? ? "TCI-#{Time.now.to_i}" : obj[:order_id]
    @return_url = obj[:return_url]
    @city = obj[:city]
    @state = 'pending'
    @description = obj[:description]
  end

  alias_method :id, :order_id

  def worldpay_request_response(request_xml)
    uri = URI.parse(WorldPay.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth(CREDENTIALS[:username], CREDENTIALS[:password])
    self.response = http.request( request, request_xml ).body
  end

  # This method create paymentService url.
  def make_payment
    worldpay_request_response(payment_xml)
    xmldoc = Nokogiri::XML( response )
    error, reference = [ xmldoc.at_xpath('//error'), xmldoc.at_xpath('//reference') ]
    if error
      errors.add(:base, error.text)
      false
    elsif reference
      self.approve_url = "#{reference.text}&successURL=#{self.return_url}"
      true
    else
      errors.add(:base, response)
      false
    end
  end

  # This method create paymentService url.
  def make_refund
    worldpay_request_response(refund_xml)
    xmldoc = Nokogiri::XML( response )
    error, refund_received = [ xmldoc.at_xpath('//error'), xmldoc.at_xpath('//ok') ]
    if error
      errors.add(:base, error.text)
    elsif refund_received
    else
      errors.add(:base, response)
    end
    self
  end

  # This method makes a capture payment request to worldpay
  def make_capture
    worldpay_request_response(capture_xml)
    xmldoc = Nokogiri::XML( response )
    error, capture_received = [ xmldoc.at_xpath('//error'), xmldoc.at_xpath('//ok') ]
    if error
      errors.add(:base, error.text)
      false
    elsif capture_received
      true
    else
      errors.add(:base, response)
      false
    end
  end

  # This method create xml service details for payment.
  def payment_xml
    "<?xml version='1.0'?>
    <!DOCTYPE paymentService PUBLIC '-//WorldPay//DTD WorldPay PaymentService v1//EN' 'http://dtd.worldpay.com/paymentService_v1.dtd'>
    <paymentService version='1.4' merchantCode='#{self.merchant_code}'>
      <submit>
        <order orderCode='#{self.order_id}'>
          <description>#{ActionController::Base.helpers.sanitize(self.description)}</description>
          <amount value='#{self.amount}' currencyCode='#{self.currency}' exponent='2'/>
          <orderContent>
            <![CDATA[]]>
          </orderContent>
          <paymentMethodMask>
            <include code='ALL'/>
          </paymentMethodMask>
          <shopper>
            <shopperEmailAddress>#{self.email}</shopperEmailAddress>
          </shopper>
          <billingAddress>
            <address>
              <firstName>#{self.first_name}</firstName>
              <lastName>#{self.last_name}</lastName>
              <address1>#{self.address_1}</address1>
              <address2>#{self.address_2}</address2>
              <address3>#{self.address_3}</address3>
              <postalCode>#{self.postal_code}</postalCode>
              <city>#{self.city}</city>
              <countryCode>#{self.country_code}</countryCode>
            </address>
          </billingAddress>
        </order>
      </submit>
    </paymentService>"
  end

  # This method create xml service details for refund process.
  def refund_xml
    "<?xml version='1.0' encoding='UTF-8'?>
    <!DOCTYPE paymentService PUBLIC '-//Worldpay//DTD Worldpay PaymentService v1//EN' 'http://dtd.wp3.rbsworldpay.com/paymentService_v1.dtd'>
    <paymentService merchantCode='#{self.merchant_code}' version='1.4'>
      <modify>
        <orderModification orderCode='#{self.order_id}'>
          <refund>
            <amount value='1' currencyCode='#{self.currency}' exponent='2'/>
          </refund>
        </orderModification>
      </modify>
    </paymentService>"
  end

  # This method returns an xml to make a capture request
  def capture_xml
    "<?xml version='1.0' encoding='UTF-8'?>
    <!DOCTYPE paymentService PUBLIC '-//Worldpay//DTD Worldpay PaymentService v1//EN' 'http://dtd.wp3.rbsworldpay.com/paymentService_v1.dtd'>
    <paymentService merchantCode='#{self.merchant_code}' version='1.4'>
      <modify>
        <orderModification orderCode='#{self.order_id}'>
          <capture>
            <amount value='#{self.amount}' currencyCode='#{self.currency}' exponent='2' debitCreditIndicator='credit'/>
          </capture>
        </orderModification>
      </modify>
    </paymentService>"
  end

  # This method return the true is responce is success.
  def success?
    !Nokogiri::XML(self.response).at_xpath('//ok').blank?
  end

  # This method make payment.
  def create
    self.valid? ? self.make_payment : false
  end

  class << self
    # url for transaction
    def url
      URL[CREDENTIALS[:mode].to_sym]
    end
  end
end
