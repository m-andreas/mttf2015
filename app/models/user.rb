class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => {email: false, login: false}
  attr_accessor :login
  belongs_to :company
  paginates_per 10
  before_create :set_default_role
  validates :username,
    :format => { with: /[a-zA-Z0-9_\.]*/ },
    :presence => true,
    :uniqueness => {
      :case_sensitive => false
    }

  def is_intern?
    return self.company_id == Company::TRANSFAIR
  end

  def is_sixt?
    return self.company_id == Company::SIXT
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
        where(conditions.to_hash).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:username].nil?
        where(conditions).first
      else
        where(username: conditions[:username]).first
      end
    end
  end

  private

    def set_default_role
      self.company = Company.sixt
    end
end
