module TheWebFellas
  module ValidatesAsDateTime

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      DEFAULT_DATE_TIME_VALIDATION_OPTIONS = {
        :before_message => "must be before %s",
        :after_message  => "must be after %s",
        :on => :save,
        :allow_nil => false
      }.freeze

      # Validates a date (a date with time will be considered invalid)
      def validates_as_date(*attr_names)
        configuration = date_time_validation_configuration({ :message => 'is an invalid date' }, attr_names)
        allow_nil = configuration.delete(:allow_nil)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast")
          next if allow_nil && raw_value.nil?
          begin
            Date.parse(raw_value) unless raw_value.is_a?(Date)
          rescue
            record.errors.add(attr_name, configuration[:message])
          else
            validate_before_and_after(record, attr_name, value, configuration, Date)
          end
        end
      end

      # Validates a date and time (stored in a Ruby Time object)
      def validates_as_date_time(*attr_names)
        configuration = date_time_validation_configuration({ :message => 'is an invalid date and time' }, attr_names)
        allow_nil = configuration.delete(:allow_nil)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          raw_value = record.send("#{attr_name}_before_type_cast")
          next if allow_nil && raw_value.nil?
          begin
            Time.parse(raw_value) unless raw_value.is_a?(Time)
          rescue
            record.errors.add(attr_name, configuration[:message])
          else
            validate_before_and_after(record, attr_name, value, configuration, Time)
          end
        end
      end

      protected

        def date_time_validation_configuration(configuration, args)
          configuration.reverse_merge!(DEFAULT_DATE_TIME_VALIDATION_OPTIONS)
          configuration.update(args.extract_options!)
          configuration.assert_valid_keys :message, :before_message, :after_message, :before, :after, :if, :unless, :on, :allow_nil
          configuration
        end

        def evaluate_limit_condition(record, option, klass)
          case option
            when Symbol then record.send(option)
            when Proc then option.call(record)
            when String then option.send("to_#{klass.name.underscore}") rescue ''
            else option
          end
        end

        def validate_before_and_after(record, attr_name, value, configuration, klass)
          [:before, :after].each do |option|
            if configuration.has_key?(option)
              limit = evaluate_limit_condition(record, configuration[option], klass)
              raise ArgumentError, "A #{klass.name} must be supplied as the :#{option} option of the configuration hash" unless limit.nil? ||
                                                                                                                                limit.is_a?(klass)
              record.errors.add(attr_name, configuration["#{option}_message".to_sym] % limit.to_s(:long)) if !limit.nil? &&
                                                                                                             (option == :before ? value > limit : value < limit)
            end
          end
        end
    end
  end
end