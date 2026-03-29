class CreatePushSubscriptions < ActiveRecord::Migration[8.0]
  def change
    create_table :push_subscriptions do |t|
      t.references :church_member, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false

      # Notification preferences
      t.boolean :notify_new_needs, null: false, default: false
      t.boolean :notify_new_services, null: false, default: false
      t.boolean :notify_new_items, null: false, default: false
      t.boolean :notify_borrow_requests, null: false, default: false

      t.timestamps
    end

    add_index :push_subscriptions, :endpoint, unique: true
  end
end
