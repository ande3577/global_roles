require File.expand_path('../../test_helper', __FILE__)

class GlobalRoleTest < ActiveSupport::TestCase
  fixtures :users, :groups_users, :roles

  def setup
    @role = Role.first
    @group = Group.first
    @user = @group.users.first
  end


  def test_create_individual_global_role
    assert new_individual_global_role.save
    assert @user.global_roles.include?(@role)
  end

  def test_create_group_global_role
    assert new_group_global_role.save
    assert @group.global_roles.include?(@role)
  end

  def test_requires_principal
    assert !new_individual_global_role(:principal => nil).save
  end

  def test_requires_role
    assert !new_individual_global_role(:role => nil).save
  end

  private
  def new_individual_global_role(options = {})
    GlobalRole.new({:principal => @user, :role => @role}.merge(options))
  end

  def new_group_global_role(options = {})
    GlobalRole.new({:principal => @group, :role => @role}.merge(options))
  end
end
