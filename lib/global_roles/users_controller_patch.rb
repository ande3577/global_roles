module GlobalRoles
  module UsersControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
  
      base.class_eval do
      end
    end
  
    module ClassMethods   
    end
  
    module InstanceMethods 

      def destroy_global_role
        @user = User.find(params[:id])
        global_role = GlobalRole.find(params[:rid])
        global_role.destroy if !global_role.inherited_role?
        respond_to do |format|
          format.html { redirect_to :controller => 'users', :action => 'edit', :tab => 'users-global-roles' }
          format.js
        end
      end


      def create_global_role
        @user = User.find(params[:id])
        @roles = params[:roles]

        if @roles.is_a?(Array)
          @roles.each{ |role_id| GlobalRole.create(:user_id => @user.id, :role_id => role_id ) }
        end  
        
        respond_to do |format|        
          format.html { redirect_to :controller => 'users', :action => 'edit', :tab => 'users-global-roles' }
          format.js
        end
      end

    end
  
  end
end