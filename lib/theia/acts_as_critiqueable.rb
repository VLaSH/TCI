module Theia
  module ActsAsCritiqueable
    module Model
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_critiqueable
          with_options :as => :critiqueable, :dependent => :destroy do |o|
            o.has_many :critiques, -> { where(:deleted_at => nil).order(:created_at)}
            o.has_many :deleted_critiques, -> {where("#{quoted_column_name('deleted_at')} IS NOT NULL")}, :class_name => 'Critique'
          end
          include InstanceMethods
        end
      end

      module InstanceMethods
        def critiqueable?(user)
          true
        end
      end
    end

    module Controller
      def self.included(base)
        base.send(:include, InstanceMethods)
        if base.respond_to?(:before_filter)
          base.before_filter(:find_critiqueable, :only => [ :index, :new, :create ])
          base.before_filter(:find_critique, :only => [ :show, :edit, :update, :delete, :destroy ])
        end
      end

      module InstanceMethods

        protected

          def find_critiqueable
            critiqueable_param = params.keys.detect { |k| k.to_s.ends_with?('_id') }
            critiqueable_type = critiqueable_param.to_s.sub(/_id$/, '').camelize.constantize
            @critiqueable = critiqueable_type.find(params[critiqueable_param])
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to("The #{critiqueable_type.human_name} you requested does not exist", :error, user_role_root_path)
          end

          def find_critique
            @critique = Critique.non_deleted.find(params[:id], :include => :critiqueable)
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to('The critique you requested does not exist', :error, user_role_root_path)
          end

          def build_critique(attributes = {})
            Critique.new(attributes) do |c|
              c.critiqueable = @critiqueable
              c.user = current_user
            end
          end

      end
    end
  end
end