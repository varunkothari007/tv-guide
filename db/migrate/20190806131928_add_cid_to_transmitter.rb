class AddCidToTransmitter < ActiveRecord::Migration[5.2]
  def change
    unless column_exists? :transmitters, :cid
    	add_column :transmitters, :cid, :integer
    end
  end
end
