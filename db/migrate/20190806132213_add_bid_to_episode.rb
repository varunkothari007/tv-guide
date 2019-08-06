class AddBidToEpisode < ActiveRecord::Migration[5.2]
  def change
  	unless column_exists? :episodes, :bid
    	add_column :episodes, :bid, :string
    end
  end
end
