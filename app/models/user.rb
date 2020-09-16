# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  devise :two_factor_authenticatable,
         :otp_secret_encryption_key => ENV['TOTP_ENCRYPTION_KEY']

  devise :two_factor_backupable, otp_number_of_backup_codes: 10

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable, :recoverable, :rememberable, :validatable,
       :fido_usf_registerable

  has_many :user_groups, dependent: :destroy
  has_many :groups, through: :user_groups
  has_many :group_permissions, through: :groups
  has_many :permissions, through: :group_permissions

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :logins, dependent: :destroy

  validates :username, presence: true, uniqueness: { case_sensitive: false }

  validate :validate_username

  attr_writer :login
  def validate_username
    if User.where(email: username).exists?
      errors.add(:username, :invalid)
    end
  end

  def self.u2f_authenticate(user, app_id, json_response, challenges)
    # binding.pry
    response = U2F::SignResponse.load_from_json(json_response)
    registration = user.fido_usf_devices
                            .find_by(key_handle: response.key_handle)
    # registration = user.fido_usf_devices.find_by_key_handle(response.key_handle)
    u2f = U2F::U2F.new(app_id)
    # binding.pry
    if registration
      u2f.authenticate!(challenges, response, registration.public_key, registration.counter)
      registration.update(counter: response.counter)
      true
    end
  rescue JSON::ParserError, NoMethodError, ArgumentError, U2F::Error
    false
  end

  def disable_two_factor!
    transaction do
      update(
        otp_required_for_login:      false,
        encrypted_otp_secret:        nil,
        encrypted_otp_secret_iv:     nil,
        encrypted_otp_secret_salt:   nil,
        otp_backup_codes:            nil
      )
      self.fido_usf_devices.destroy_all # rubocop: disable Cop/DestroyAll
    end
  end

  def asserted_attributes
    {
      groups: { getter: :groups },
      email: {
        getter: :email,
          name_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS,
          name_id_format: Saml::XML::Namespaces::Formats::NameId::EMAIL_ADDRESS
      },
      username: {
        getter: :username,
          # name_format: Saml::XML::Namespaces::Formats::NameId::USERNAME,
          # name_id_format: Saml::XML::Namespaces::Formats::NameId::USERNAME
      },
      name: {
        getter: :name,
          # name_format: Saml::XML::Namespaces::Formats::NameId::NAME,
          # name_id_format: Saml::XML::Namespaces::Formats::NameId::NAME
      }
    }
  end

  def admin?
    @admin ||= groups.include?(Group.find_by(name: 'administrators'))
  end

  def to_s
    username || email
  end
  # def groups
  #   %i[awesome internal]
  # end

  # def roles
  #   %i[admin staff]
  # end

  def login
    @login || self.username || self.email
  end

  def self.by_id_and_login(id, login)
    where(id: id).database_authentication_rel({login: login})
  end

  def self.database_authentication_rel(conditions)
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }])
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h)
    end
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    database_authentication_rel(conditions).first
  end

  def two_factor_enabled?
    two_factor_otp_enabled? || two_factor_u2f_enabled?
  end

  def two_factor_otp_enabled?
    otp_required_for_login?
  end

  def two_factor_u2f_enabled?
    if fido_usf_devices.loaded?
      fido_usf_devices.any?
    else
      fido_usf_devices.exists?
    end
  end
end
