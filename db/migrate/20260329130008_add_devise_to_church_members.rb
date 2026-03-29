# frozen_string_literal: true

class AddDeviseToChurchMembers < ActiveRecord::Migration[8.0]
  def self.up
    change_table :church_members do |t|
      ## Database authenticatable
      # email already exists, just ensure not null with default
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Profile fields
      t.string  :phone
      t.boolean :show_email, default: false
      t.boolean :show_in_directory, default: true
    end

    # Update email column to have not null constraint
    change_column_null :church_members, :email, false
    change_column_default :church_members, :email, ""

    # Remove old non-unique index on email if it exists, keep the unique one
    remove_index :church_members, :email, if_exists: true
    add_index :church_members, :email, unique: true
    add_index :church_members, :reset_password_token, unique: true
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
