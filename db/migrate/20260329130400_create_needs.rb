class CreateNeeds < ActiveRecord::Migration[8.0]
  def change
    create_table :needs do |t|
      t.string :title, null: false
      t.text :description
      t.string :contact_info
      t.string :status, null: false, default: "open"
      t.datetime :expires_at, null: false
      t.references :church_member, null: false, foreign_key: true
      t.references :church, null: false, foreign_key: true

      t.timestamps
    end

    add_index :needs, :status
    add_index :needs, :expires_at
    add_index :needs, [ :church_id, :status ]
  end
end
