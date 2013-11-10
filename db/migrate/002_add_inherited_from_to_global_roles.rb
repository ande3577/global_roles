class AddInheritedFromToGlobalRoles < ActiveRecord::Migration
  def change
    add_column :global_roles, :inherited_from_id, :integer
  end
end
