class CreateGeographicSignups < ActiveRecord::Migration[8.0]
  def change
    create_table :geographic_signups do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :suburb_name, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :country_code, limit: 2
      t.string :state_code, limit: 10
      t.string :postcode, limit: 10
      t.boolean :email_verified, default: false
      t.string :verification_token
      t.datetime :verified_at

      t.timestamps
    end

    add_index :geographic_signups, :email, unique: true
    add_index :geographic_signups, [:latitude, :longitude]
    add_index :geographic_signups, [:suburb_name, :country_code]
    add_index :geographic_signups, :verification_token
  end
end
