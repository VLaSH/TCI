class Payment < PayPal::SDK::REST::Payment
  include ActiveModel::Validations

  def create
    return false if invalid?
    super
  end

  def error=(error)
    error["details"].each do |detail|
      errors.add detail["field"], detail["issue"]
    end if error and error["details"]
    super
  end

  def add_payment_method(user)
    self.payer.payment_method = "paypal"
  end

  def order=(subscription)
    self.intent = "sale"
    add_payment_method(subscription)
    self.transactions = {
      :amount => {
        :total => subscription.amount,
        :currency => "USD" },
      :item_list => {
        :items => { :name => "subscriptions", :sku => "subscriptions", :price => subscription.amount, :currency => "USD", :quantity => 1 }
      },
      :description => subscription.description
     }
     self.redirect_urls = {
       :return_url => subscription.return_url,
       :cancel_url => subscription.return_url
     }
  end

  def payment_status
    sale.state
  end

  def sale
    transactions[0].related_resources[0].sale
  end

end
