module TheWebFellas
  module ValidatesAsPostalCode

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
        # Validates a postal code using country specific rules when appropriate
        def validates_as_postal_code(*attr_names)
          configuration = {
                            :message          => 'is invalid',
                            :too_long_message => "is too long (maximum is %d characters)",
                            :maximum_length   => 0,
                            :on               => :save,
                            :allow_nil        => false,
                            :allow_blank      => false
                          }

          configuration.update(attr_names.extract_options!)

          configuration.assert_valid_keys :message,
                                          :too_long_message,
                                          :maximum_length,
                                          :country,
                                          :if,
                                          :unless,
                                          :on,
                                          :allow_nil,
                                          :allow_blank

          # Get the maximum length (if specified)
          maximum_length = configuration[:maximum_length]
          raise ArgumentError, "A non-negative Integer must be supplied as the :maximum_length option of the configuration hash" unless maximum_length.is_a?(Integer) and maximum_length >= 0

          validates_each(attr_names, configuration) do |record, attr_name, value|

            # Get the country
            country = case configuration[:country]
                        when Symbol then record.send(configuration[:country])
                        when Proc then configuration[:country].call(record)
                        else configuration[:country]
                      end
            raise ArgumentError, "A String must be supplied as the :country option of the configuration hash" unless country.is_a?(String) || country.nil?

            case country.to_s.mb_chars.upcase.to_s
              when 'GB' then record.errors.add(attr_name, configuration[:message]) unless value =~ /^((([A-PR-UWYZ]\d{1,2})|([A-PR-UWYZ][A-HK-Y]\d{1,2})|([A-PR-UWYZ]\d[A-HJKSTUW])|([A-PR-UWYZ][A-HK-Y]\d[ABEHMNPRVWXY]))\s\d[ABD-HJLNP-UWXYZ]{2})|GIR\s0AA$/i
              else record.errors.add(attr_name, configuration[:too_long_message] % maximum_length) if maximum_length > 0 && value.mb_chars.length > maximum_length
            end
          end
        end
    end
  end
end