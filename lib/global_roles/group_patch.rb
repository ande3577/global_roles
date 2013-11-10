module GlobalRoles
  module GroupPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)  
  
      base.class_eval do
        has_many :x_roles, :class_name => 'GlobalRole', :foreign_key => 'user_id'
        has_many :global_roles, :source => :role, :through => :x_roles
        alias_method_chain :user_added, :global_roles          
        alias_method_chain :user_removed, :global_roles
      end
    end
  
    module ClassMethods   
    end
  
    module InstanceMethods 
      def user_added_with_global_roles(user)
        user_added_without_global_roles(user)
        self.x_roles.each do |x_role|
          GlobalRole.create_inherited_role(user, x_role)
        end
      end

      def user_removed_with_global_roles(user)
        user_added_without_global_roles(user)
        self.x_roles.each do |x_role|
          x_role.destroy_inherited_roles_for_user(user)
        end
      end
    end
  
  end
end
