module Theia
  module ActsAsDiscussable
    module Model
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def acts_as_discussable
          with_options :as => :discussable, :dependent => :destroy do |o|
            o.has_many :forum_topics, -> { where(:deleted_at => nil).order (:created_at)}
            o.has_many :deleted_forum_topics, -> where{("#{quoted_column_name('deleted_at')} IS NOT NULL")}, :class_name => 'ForumTopic'
          end
          include InstanceMethods
        end
      end

      module InstanceMethods
        def discussable?(user)
          true
        end
      end
    end

    module Controller
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.helper_method(:polymorphic_forum_topics_path) if base.respond_to?(:helper_method)
      end

      module InstanceMethods

        protected

          def find_discussable
            unless (discussable_param = params.keys.detect { |k| k.to_s.ends_with?('_id') }).blank?
              discussable_type = discussable_param.to_s.sub(/_id$/, '').camelize.constantize
              @discussable = discussable_type.find(params[discussable_param])
            end
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to("The #{discussable_type.human_name} you requested does not exist", :error, user_role_root_path)
          end

          def find_forum_topic
            forum_topic_id = params.has_key?(:forum_topic_id) ? params[:forum_topic_id] : params[:id]
            if (@forum_topic = ForumTopic.non_deleted.find_by_id(forum_topic_id, :include => :discussable)).nil?
              flash_and_redirect_to('The forum topic you requested does not exist', :error, user_role_root_path)
            elsif !@forum_topic.readable?(current_user)
              flash_and_redirect_to('You do not have permission to access that page', :error, user_role_root_path)
            end
          end

          def find_forum_post
            @forum_post = ForumPost.non_deleted.find(params[:id], :include => { :topic => :discussable })
          rescue ActiveRecord::RecordNotFound
            flash_and_redirect_to('The forum post you requested does not exist', :error, user_role_root_path)
          end

          def build_forum_topic(attributes = {})
            forum_topic = @discussable.nil? ? ForumTopic.new(attributes) : @discussable.forum_topics.build(attributes)
            forum_topic.user = current_user
            forum_topic
          end

          def build_forum_post(attributes = {})
            ForumPost.new(attributes) do |p|
              p.user = current_user
              p.topic = @forum_topic
            end
          end

      end
    end
  end
end