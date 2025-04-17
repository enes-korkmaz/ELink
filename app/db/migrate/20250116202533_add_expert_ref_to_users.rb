class AddExpertRefToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :expert, null: true, foreign_key: true
  end
end
