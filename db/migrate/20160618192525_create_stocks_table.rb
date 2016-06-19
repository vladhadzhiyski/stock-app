class CreateStocksTable < ActiveRecord::Migration
  def change
    create_table :stocks do |t|
      t.string :symbol, null: false
      t.string :name
      t.integer :last_sale
      t.string :market_cap
      t.string :ipo_year
      t.string :sector
      t.string :industry
      t.string :summary_quote

      t.timestamps null: false
    end
  end
end
