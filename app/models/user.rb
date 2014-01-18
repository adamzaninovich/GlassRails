class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:google_oauth2]

  attr_accessible :email, :password, :password_confirmation, :remember_me, :name

  def self.find_for_google_oauth2 access_token, signed_in_resource=nil
    data = access_token.info
    User.where(email: data["email"]).first || begin
      user_options = {
        name: data["name"],
        email: data["email"],
        password: Devise.friendly_token[0,20]
      }
      User.create(user_options).tap do |user|
        user.access_token = access_token.credentials.token
        user.refresh_token = access_token.credentials.refresh_token
        user.token_expires_at = Time.at(access_token.credentials.expires_at)
      end
    end
  end

  def get_mirror_api_client
    token = Mirror::Api::OAuth.new(ENV["GOOGLE_KEY"], ENV["GOOGLE_SECRET"], refresh_token).get_access_token
    Mirror::Api::Client.new token
  end
end
