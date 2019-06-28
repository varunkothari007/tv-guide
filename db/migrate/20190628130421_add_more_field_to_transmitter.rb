class AddMoreFieldToTransmitter < ActiveRecord::Migration[5.2]
  def change
    add_column :transmitters, :tv_url, :string
    add_column :transmitters, :title, :string
  end
end
