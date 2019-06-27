class CreateTransmitters < ActiveRecord::Migration[5.2]
  def change
    create_table :transmitters do |t|
    	t.string :name
      t.timestamps
    end
  end
end

#transmitters => Tv Channel List 
