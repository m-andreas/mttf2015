class UniqueInvitationToken < ActiveRecord::Migration
  def change
    execute "CREATE UNIQUE NONCLUSTERED INDEX index_users_on_tokenname ON dbo.users (invitation_token) WHERE invitation_token IS NOT NULL;"
  end
end
