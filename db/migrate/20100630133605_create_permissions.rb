class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.integer :user_id
      t.integer :datatable_id

      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
