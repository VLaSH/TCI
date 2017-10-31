class Money

  @@symbols = {
    'USD' => '$',
    'GPB' => '£',
    'JPY' => '¥',
    'EUR' => '€'
  }

  def format(*rules)
    return self.class.zero if zero? && self.class.zero

    rules = rules.flatten

    formatted = @@symbols[currency].to_s + (rules.include?(:no_fraction) ? 0 : 2).to_s

    if rules.include?(:with_currency)
      formatted << " "
      formatted << '<span class="currency">' if rules.include?(:html)
      formatted << currency
      formatted << '</span>' if rules.include?(:html)
    end
    formatted
  end
end
