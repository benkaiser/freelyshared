class CreateServicesListings < ActiveRecord::Migration[8.0]
  def change
    create_table :services_listings do |t|
      t.string :title, null: false
      t.text :description
      t.string :contact_preference
      t.references :church_member, null: false, foreign_key: true
      t.references :church, null: false, foreign_key: true

      t.timestamps
    end
  end
end
