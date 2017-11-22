class ExchangeRate < ActiveRecord::Base

  attr_accessible :base_currency, :counter_currency, :rate

  validates_presence_of :base_currency, :counter_currency

  with_options allow_blank: true do |o|
    o.validates_format_of :base_currency, :counter_currency, with: /\A[A-Z]{3}\Z/
    o.validates_uniqueness_of :counter_currency, scope: :base_currency, message: 'already exists'
  end

  validates_numericality_of :rate, greater_than_or_equal_to: BigDecimal.new('0.0'), less_than_or_equal_to: BigDecimal.new('999999.9999')

  def self.for_symbol symbol
    symbol = symbol.to_s.split('/')
    where(base_currency: symbol.first, counter_currency: symbol.last)
  end

  before_validation do |e|
    [ :base_currency, :counter_currency ].each { |attr| e.send("#{attr}=", e.send(attr).to_s.mb_chars.strip.upcase.to_s) }
    true
  end

  after_save :expire_cache
  after_destroy :expire_cache

  def symbol
    "#{base_currency}/#{counter_currency}"
  end

  def self.cache_key(symbol)
    "#{model_name.cache_key}/#{symbol}"
  end

  def cache_key
    self.class.cache_key(new_record? ? 'new' : symbol)
  end

  def self.exchange(money, currency)
    base_currency, counter_currency = money.currency.to_s.upcase, currency.to_s.upcase
    return money if base_currency == counter_currency

    exchange_rate = Rails.cache.fetch(cache_key("#{base_currency}/#{counter_currency}")) do
      where(base_currency: base_currency, counter_currency: counter_currency).first
    end

    unless exchange_rate.nil?
      Money.new((money.cents * exchange_rate.rate).floor, currency, money.precision)
    else
      raise Money::MoneyError.new("Missing exchange rate #{base_currency}/#{counter_currency}")
    end
  end

  protected

    def expire_cache
      Rails.cache.delete(cache_key)
      true
    end

end
