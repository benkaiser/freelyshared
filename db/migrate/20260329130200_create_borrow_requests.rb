class CreateBorrowRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :borrow_requests do |t|
      t.references :item, null: false, foreign_key: true
      t.references :requester, null: false, foreign_key: { to_table: :church_members }
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :phone
      t.boolean :owner_confirmed, null: false, default: false
      t.boolean :borrower_confirmed, null: false, default: false
      t.string :status, null: false, default: "pending"

      t.timestamps
    end

    add_index :borrow_requests, :status
    add_index :borrow_requests, [ :item_id, :status ]
  end
end
