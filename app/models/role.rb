class Role < ActiveRecord::Base
  has_many :people, :through => :affiliations
  has_many :affiliations
  belongs_to :role_type
  
  def emeritus?
    name =~ /^Emeritus/
  end
  
  def committee?
    name =~ /Committee/ || name =~/Network Representatives/
  end
  
  def Role.data_roles
    self.find(:all, :conditions => ["role_type_id = ?", RoleType.find_by_name('lter_dataset')])
  end
end
