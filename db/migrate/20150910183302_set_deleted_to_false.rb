class SetDeletedToFalse < ActiveRecord::Migration
  def up
    Driver.find_each(batch_size: 1000) do |driver|
      driver.deleted = false
      driver.save
    end
    User.find_each(batch_size: 1000) do |user|
      user.deleted = false
      user.save
    end
  end
end
