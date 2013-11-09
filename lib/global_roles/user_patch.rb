module GlobalRoles
  module UserPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        has_many :x_roles, :class_name => 'GlobalRole', :foreign_key => 'user_id' #, :include => :roles
        has_many :global_roles, :source => :role, :through => :x_roles  
        alias_method_chain :roles_for_project, :global_roles
        alias_method_chain :allowed_to?, :global_roles
      end
    end

    module ClassMethods
    end

    module InstanceMethods

      def roles_for_project_with_global_roles(project)
        roles = roles_for_project_without_global_roles(project)
        if should_add_global_roles?(project)
          roles += global_roles_with_groups
          roles.uniq!
        end
        roles
      end

      def allowed_to_with_global_roles?(action, context, options = {}, &block)
        return true if allowed_to_without_global_roles?(action, context, options, &block)
        if context.nil? && options[:global]
          global_roles_with_groups.any? {|role|
            role.allowed_to?(action) &&
            (block_given? ? yield(role, self) : true)
          }
        else
          false
        end
      end

      private
      def should_add_global_roles?(project)
        project && project.is_public? && !project.archived?
      end

      def global_roles_with_groups
        self.global_roles + self.groups.map { |group| group.global_roles.all }.flatten
      end
    end

  end
end