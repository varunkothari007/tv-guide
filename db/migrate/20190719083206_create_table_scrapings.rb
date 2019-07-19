class CreateTableScrapings < ActiveRecord::Migration[5.2]
  def change
    create_table :scrapings do |t|
    	t.string :which_date
      t.boolean :status
    end
  end
end
