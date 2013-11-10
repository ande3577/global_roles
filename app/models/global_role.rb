class GlobalRole < ActiveRecord::Base
  unloadable

  belongs_to :role
  validates_presence_of :role
  belongs_to :principal, :foreign_key => :user_id
  validates_presence_of :principal
  belongs_to :inherited_from,  :class_name => "GlobalRole"
  has_many :member_global_roles, :class_name => "GlobalRole", :foreign_key => :inherited_from_id, :dependent => :destroy

  after_create :create_individual_roles

  def inherited_role?
    inherited_from
  end

  def destroy_inherited_roles_for_user(user)
    self.member_global_roles.where(:user_id => user.id).each(&:destroy)
  end

  def self.create_inherited_role(user, inherited_from)
    GlobalRole.create!(:principal => user, :role => inherited_from.role, :inherited_from => inherited_from)
  end

  private

  def create_individual_roles
    if self.principal.is_a?(Group)
      self.principal.users.each do |u|
        GlobalRole.create_inherited_role(u, self)
      end
    end
  end

end
