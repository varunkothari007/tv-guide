class CreateRatings < ActiveRecord::Migration[5.2]
  def change
    create_table :ratings do |t|
    	t.references :episode, index: true
    	t.string :source
    	t.integer :rating
      t.timestamps
    end
  end
end
