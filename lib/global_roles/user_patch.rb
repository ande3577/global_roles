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

      def global_permission_to?(controller, action)
        return true if admin? 
                
        roles = (global_roles + groups.collect {|gr| gr.global_roles}.flatten).uniq
        roles << Role.anonymous unless self.logged?

        not roles.detect { |r| 
          r.allowed_to?({:controller => controller, :action => action}) 
        }.nil?
     
      end

      def roles_for_project_with_global_roles(project)
        add_global_roles(roles_for_project_without_global_roles(project), project)
      end

      def add_global_roles(roles, project)
        roles = (roles + self.global_roles).uniq if should_add_global_roles?(project)
        roles
      end

      def should_add_global_roles?(project)
        project && project.is_public? && !project.archived?
      end

      def allowed_to_with_global_roles?(action, context, options = {}, &block)
        return true if allowed_to_without_global_roles?(action, context, options, &block)
        if context.nil? && options[:global]
          self.global_roles.any? {|role|
            role.allowed_to?(action) &&
            (block_given? ? yield(role, self) : true)
          }
        else
          false
        end
      end

    end

  end
end