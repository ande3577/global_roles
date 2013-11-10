require File.expand_path('../../test_helper', __FILE__)

class GroupTest < ActiveSupport::TestCase
  fixtures :users, :roles, :groups_users, :members, :member_roles
  
  def setup
  	@admin = User.where(:admin => true).first
  	@user = User.logged.where(:admin => false).first
  	@global_role = Role.find(2)
    @group = Group.first
    @x_role = GlobalRole.create!(:role => @global_role, :principal => @group)
  end

  def test_creates_individual_global_role_when_adding_user
    add_user_to_group
    assert @user.global_roles.include?(@global_role)
  end

  def test_destroys_individual_global_role_when_removing_user
    add_user_to_group
    remove_user_from_group
    assert !@user.global_roles.include?(@global_role)
  end

  private
  def add_user_to_group(user = @user)
    @group.users << user
    @group.save!
    user.reload
  end

  def remove_user_from_group(user = @user)
    @group.users.delete(user)
    @group.save!
    user.reload
  end

end
