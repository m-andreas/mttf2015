class AddUsernameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :username, :string
    #add_index :users, :username, unique: true
    execute "CREATE UNIQUE NONCLUSTERED INDEX index_users_on_username ON dbo.users (username) WHERE username IS NOT NULL;"
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
