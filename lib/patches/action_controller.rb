# Patch polymorphic routes to allow a symbol as the last element of the array parameter
# Taken from this patch: http://rails.lighthouseapp.com/projects/8994/tickets/1384-polymorphic_url-should-allow-a-symbol-in-place-of-a-record
module ActionController
  module PolymorphicRoutes
    private
      def extract_namespace(record_or_hash_or_array)
        return "" unless record_or_hash_or_array.is_a?(Array)

        namespace_keys = []
        while (key = record_or_hash_or_array.first) && key.is_a?(String) || key.is_a?(Symbol)
          break if record_or_hash_or_array.size == 1 && key.is_a?(Symbol)
          namespace_keys << record_or_hash_or_array.shift
        end

        namespace_keys.map {|k| "#{k}_"}.join
      end
  end
end