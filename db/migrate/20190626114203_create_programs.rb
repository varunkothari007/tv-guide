class CreatePrograms < ActiveRecord::Migration[5.2]
  def change
    create_table :programs do |t|
    	t.references :transmitter, index: true 
    	t.string :genre
    	t.string :branch
    	t.string :name 
    	t.string :thumb_type
      t.timestamps
    end
  end
end
