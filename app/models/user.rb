require "google/api_client"
require "rest_client"

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

  def get_client
    client = Google::APIClient.new
    client.authorization.scope = 'https://www.googleapis.com/auth/calendar'
    client.authorization.access_token = get_current_token
    client
  end

  def get_current_token
    if (access_token.nil? || (token_expires_at.nil? || token_expires_at < Time.now))
      data = {
        :client_id => ENV["GOOGLE_KEY"],
        :client_secret => ENV["GOOGLE_SECRET"],
        :refresh_token => user.refresh_token,
        :grant_type => "refresh_token"
      }
      @response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", data)
      puts @response.to_json
      if @response["access_token"].present?
        self.access_token = @response["access_token"]
        self.token_expires_at = Time.at(Time.now.to_i + @response["expires_in"])
        save
      end
    end
    access_token
  end
end
