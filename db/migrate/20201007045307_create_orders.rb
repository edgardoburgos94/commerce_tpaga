class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.float :cost
      t.string :user_ip_address

      t.timestamps
    end
  end
end
