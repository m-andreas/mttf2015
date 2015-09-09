class AddOldUsers < ActiveRecord::Migration
  def up
    StLogin.find_each(batch_size: 1000) do |old_user|
      if [1,2].include?( old_user.FirmaID )
        new_user = User.new(:password => old_user.Passwort.strip)
        new_user.username = old_user.Login.strip
        if old_user.EMail.to_s.strip.empty?
          new_user.email = "test@test.de"
        else
          new_user.email = old_user.EMail.strip
        end
        new_user.first_name = old_user.Vorname.strip
        new_user.last_name = old_user.Nachname.strip
        new_user.company_id = old_user.FirmaID
        new_user.save
        puts new_user.inspect
      end
    end
  end

  def down
    User.delete_all
  end
end
