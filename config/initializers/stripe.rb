Rails.configuration.stripe = {
  :publishable_key => "pk_live_Q1p1b9cl5LJl2IhWi2AbgdZy",
  :secret_key      => "sk_live_6AxhJYrCeoVRYihubqVqbS6H"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
