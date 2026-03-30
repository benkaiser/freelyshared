class DropGeographicSignups < ActiveRecord::Migration[8.0]
  def change
    drop_table :geographic_signups do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :suburb_name, null: false
      t.float :latitude
      t.float :longitude
      t.string :country_code, default: "AU"
      t.string :state_code
      t.string :postcode
      t.string :verification_token
      t.boolean :verified, default: false
      t.timestamps

      t.index :email, unique: true
      t.index [ :latitude, :longitude ]
      t.index [ :suburb_name, :country_code ]
      t.index :verification_token
    end
  end
end
