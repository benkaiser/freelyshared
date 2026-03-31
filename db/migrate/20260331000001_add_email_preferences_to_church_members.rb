class AddEmailPreferencesToChurchMembers < ActiveRecord::Migration[8.0]
  def change
    add_column :church_members, :email_notify_new_needs, :boolean, null: false, default: true
    add_column :church_members, :email_notify_new_items, :boolean, null: false, default: false
    add_column :church_members, :email_notify_new_services, :boolean, null: false, default: false
    add_column :church_members, :email_notify_church_activation, :boolean, null: false, default: true
  end
end
