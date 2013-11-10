class GlobalRole < ActiveRecord::Base
  unloadable

  belongs_to :role
  validates_presence_of :role
  belongs_to :principal, :foreign_key => :user_id
  validates_presence_of :principal

end
