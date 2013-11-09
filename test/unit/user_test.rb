require File.expand_path('../../test_helper', __FILE__)

class UserTest < ActiveSupport::TestCase
  fixtures :projects, :users, :roles, :enabled_modules, :groups_users
  
  def setup
  	@admin = User.where(:admin => true).first
  	@user = User.logged.where(:admin => false).first
  	@project = Project.active.where(:is_public => true).first
  	@project_role = @user.roles_for_project(@project).first
  	@global_role = Role.find(2)
  	@x_role = GlobalRole.create!(:role => @global_role, :principal => @user)
  	@user.reload
    @group = Group.first
    @group.users << @user
    @group.save!
  end

  def test_global_role_added_to_roles_for_project
  	assert @user.roles_for_project(@project).include?(@global_role)
  end

  def test_global_role_of_group_added_to_roles_for_project
    change_to_group_role
    assert @user.roles_for_project(@project).include?(@global_role)
  end

  def test_global_role_still_includes_project_roles
  	assert @user.roles_for_project(@project).include?(@project_role)
  end

  def test_global_role_not_added_to_private_project
  	make_project_private
  	assert !@user.roles_for_project(@project).include?(@global_role)
  end

  def test_private_project_still_includes_project_roles
  	make_project_private
  	assert @user.roles_for_project(@project).include?(@project_role)
  end

  def test_global_role_not_added_to_archived_project
  	@project.archive
  	assert @user.roles_for_project(@project).empty?
  end

  def test_allowed_globally_returns_true_for_global_role
    destroy_project_membership
    add_global_permission

    assert @user.allowed_to?(:add_project, nil, :global => true)
  end

  def test_allowed_globally_uses_group_permissions
    destroy_project_membership
    add_global_permission
    change_to_group_role

    assert @user.allowed_to?(:add_project, nil, :global => true)
  end

  def test_allowed_globally_returns_false_if_not_have_global_role
  	destroy_project_membership
    assert !@user.allowed_to?(:add_project, nil, :global => true)
  end

  def test_existing_global_permissons_still_observed
  	assert @user.allowed_to?(:add_project, nil, :global => true)
  end

  private
  def change_to_group_role
    @x_role.principal = @group
    @x_role.save!
    @user.reload
  end

  def make_project_private
  	@project.update_attribute(:is_public, false)
  	@project.reload
  end

  def destroy_project_membership
    @user.memberships.destroy_all
    @user.reload
  end

  def add_global_permission
    @global_role.add_permission!(:add_project)
  end

end
