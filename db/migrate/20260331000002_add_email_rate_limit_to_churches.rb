class AddEmailRateLimitToChurches < ActiveRecord::Migration[8.0]
  def change
    add_column :churches, :last_need_email_sent_at, :datetime
    add_column :churches, :last_item_email_sent_at, :datetime
    add_column :churches, :last_service_email_sent_at, :datetime
  end
end
