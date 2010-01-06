class StudyHasManyDatasets < ActiveRecord::Migration
  def self.up
    add_column :datasets, :study_id, :integer
  end

  def self.down
    remove_column :datasets, :study_id
  end
end
