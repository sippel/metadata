class Protocol < ActiveRecord::Base
  belongs_to :dataset
  belongs_to :person
end