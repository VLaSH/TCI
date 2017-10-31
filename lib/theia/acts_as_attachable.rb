module Theia
  module ActsAsAttachable
    module Model
      def self.included(base)
        base.extend(ClassMethods)
      end

#:conditions => { :deleted_at => nil }

      module ClassMethods
        def acts_as_attachable
          with_options :as => :attachable, :class_name => '::Attachment', :dependent => :destroy do |o|
            o.has_many :attachments, -> { where(:deleted_at => nil).order('attachments.position ASC, attachments.created_at ASC')} do
              def images
                find_all { |a| a.image? }
              end

              def non_images
                reject { |a| a.image? }
              end
            end
            o.has_many :deleted_attachments, -> { where("#{quoted_column_name('deleted_at')} IS NOT NULL")}
          end
          include InstanceMethods
        end
      end

      module InstanceMethods
        def attachable?(user)
          true
        end
      end
    end

    module Controller
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.helper_method(:polymorphic_attachments_path, :attachable_is_current_user?) if base.respond_to?(:helper_method)
      end

      module InstanceMethods

        protected
          def dictionary
            {'Submission' => 'AssignmentSubmission'}
          end

          def nestable
            {'AssignmentSubmission' => false}
          end

          def find_attachable
            if params.has_key?(:attachment) && params[:attachment].has_key?(:attachable_type) && params[:attachment].has_key?(:attachable_id)
              @attachable = params[:attachment][:attachable_type].constantize.find_by_id(params[:attachment][:attachable_id])
            else
              attachable_param = params.keys.detect { |k| k.to_s.ends_with?('_id') }
              @attachable = unless attachable_param.blank?
                attachable_type = attachable_param.to_s.sub(/_id$/, '').camelize
                attachable_type = dictionary[attachable_type] if dictionary.has_key?(attachable_type)
                attachable_type = attachable_type.constantize
                attachable_type.find(params[attachable_param])
              else
                current_user
              end
            end
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to("The #{attachable_type.human_name} you requested does not exist", :error, user_role_root_path)
          end

          def find_attachment
            @attachment = Attachment.non_deleted.find(params[:id], :include => :attachable)
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to('The attachment you requested does not exist', :error, user_role_root_path)
          end

          def build_attachment(attributes = {})
            @attachable.attachments.build(attributes.except(:asset)) do |a|
              a.asset = attributes[:asset]
              a.owner = current_user
            end
          end

          def polymorphic_attachments_path(attachable, options = {})
            record = options.has_key?(:record) ? options.delete(:record) : options.delete(:singular) ? :attachment : :attachments
            nesting = nestable.has_key?(attachable.class.name) ? nestable[attachable.class.name] : true
            attachable = dictionary.key(attachable.class.name).tableize.downcase.chop if dictionary.key(attachable.class.name)
            polymorphic_path([ current_user.role, (attachable_is_current_user?(attachable) ? nil : nesting ? attachable : nil), record ], options)
          end

          def attachable_is_current_user?(attachable)
            attachable.is_a?(User) && current_user?(attachable) && !current_user.administrator?
          end

      end
    end
  end
end
