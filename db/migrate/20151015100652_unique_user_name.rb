class UniqueUserName < ActiveRecord::Migration
  def up
    execute "CREATE UNIQUE NONCLUSTERED INDEX index_users_on_username ON dbo.users (username) WHERE username IS NOT NULL;"
  end
end
