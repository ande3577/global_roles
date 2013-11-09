require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :projects, :users, :members, :member_roles, :roles, :enabled_modules
  
  def setup
  end
  
  def test_add_global_role
  	pending
  end
  
end
