class CreateChurchesAndMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :churches do |t|
      t.string :name, null: false
      t.string :location_name, null: false
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :country_code, limit: 2
      t.string :state_code, limit: 10
      t.string :postcode, limit: 10
      t.string :status, null: false, default: "pending" # pending or ready
      t.datetime :ready_at

      t.timestamps
    end

    create_table :church_members do |t|
      t.references :church, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.boolean :email_verified, default: false
      t.string :verification_token
      t.datetime :verified_at
      t.boolean :is_registrant, default: false # the person who registered the church

      t.timestamps
    end

    add_index :churches, :name
    add_index :churches, :status
    add_index :churches, [:latitude, :longitude]
    add_index :church_members, :email, unique: true
    add_index :church_members, :verification_token
  end
end
