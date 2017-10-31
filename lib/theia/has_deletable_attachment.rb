module Theia
  module HasDeletableAttachment

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_deletable_attachment(name)
        attr_accessible "delete_#{name}"
        before_validation "delete_#{name}_before_validation"

        define_method("delete_#{name}=") do |value|
          instance_variable_set("@delete_#{name}", value.respond_to?(:to_i) ? !value.to_i.zero? : value)
        end

        define_method("delete_#{name}") do
          !!instance_variable_get("@delete_#{name}")
        end
        alias_method "delete_#{name}?", "delete_#{name}"

        define_method("delete_#{name}_before_validation") do
          if send("#{name}").respond_to?("dirty?")
            send("#{name}=", nil) if send("delete_#{name}?") && !send("#{name}").dirty?
          else
            send("#{name}=", nil) if send("delete_#{name}?")
          end
          true
        end
        protected("delete_#{name}_before_validation")
      end
    end

  end
end