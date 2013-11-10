require File.expand_path('../../test_helper', __FILE__)

class GlobalRoleTest < ActiveSupport::TestCase
  fixtures :users, :groups_users, :roles

  def setup
    @role = Role.first
    @group = Group.first
    @user = @group.users.first
  end


  def test_create_individual_global_role
    global_role = new_individual_global_role
    assert global_role.save
    assert @user.global_roles.include?(@role)
    assert !global_role.inherited_role?
  end

  def test_create_group_global_role
    global_role = new_group_global_role
    assert global_role.save
    assert @group.global_roles.include?(@role)
    assert !global_role.inherited_role?
  end

  def test_requires_principal
    assert !new_individual_global_role(:principal => nil).save
  end

  def test_requires_role
    assert !new_individual_global_role(:role => nil).save
  end

  def test_creating_a_global_group_role_creates_roles_for_members
    global_role = create_group_global_role
    assert @user.global_roles.include?(@role)
  end

  def test_creating_a_global_role_sets_up_inheritance
    global_role = create_group_global_role
    individual_role = GlobalRole.where(:user_id => @user.id).first
    assert_equal global_role, individual_role.inherited_from
    assert_equal individual_role, global_role.member_global_roles.first
    assert individual_role.inherited_role?
  end

  def test_destroys_individual_role_when_destroying_group_role
    create_group_global_role.destroy
    assert !@user.global_roles.include?(@role)
  end

  private
  def new_individual_global_role(options = {})
    GlobalRole.new({:principal => @user, :role => @role}.merge(options))
  end

  def new_group_global_role(options = {})
    GlobalRole.new({:principal => @group, :role => @role}.merge(options))
  end

  def create_group_global_role(options = {})
    GlobalRole.create({:principal => @group, :role => @role}.merge(options))
  end
end
