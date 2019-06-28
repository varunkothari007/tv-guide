class AddRemoveFieldToProgram < ActiveRecord::Migration[5.2]
  def change
  	remove_column :programs, :thumb_type
  end
end
