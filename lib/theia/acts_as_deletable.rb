module Theia
  module ActsAsDeletable

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def acts_as_deletable
        scope :deleted, -> { where("#{quoted_table_name}.#{quoted_column_name('deleted_at')} IS NOT NULL")}
        scope :non_deleted, -> { where(:deleted_at => nil)}

        include InstanceMethods
      end
    end

    module InstanceMethods
      def deleted?
        !deleted_at.nil?
      end

      def delete!
        new_record? ? false : update_attribute(:deleted_at, Time.current)
      end

      def undelete!
        new_record? ? false : update_attribute(:deleted_at, nil)
      end
    end
  end
end