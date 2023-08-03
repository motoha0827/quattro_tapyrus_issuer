# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :signed_in?, only: %i[show]

  def show
    @user = current_user
  end

  def new; end

  def create
    user = User.new(user_params)
    user.build_account.save!
    user.build_wallet.save!
    services_json = {
                     "services": [
                       {
                         "id": 'quattrowallet',
                         "type": 'QuattroWallet',
                         "serviceEndpoint": "https://issuer.quattro.example.com/wallets/#{user.wallet.id}"
                       }
                     ]
                   }.to_json

    response = Net::HTTP.post(
      URI("#{ENV['DID_SERVICE_URL']}/did/create"),
      services_json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    did_long_form = body['did']
    signing_key = body['signingKey'].to_json
    recovery_key = body['recoveryKey'].to_json
    update_key = body['updateKey'].to_json

    Did.create!(wallet: user.wallet, did_long_form:, signing_key:, recovery_key:, update_key:)

    sign_in(user)

    redirect_to wallet_path
  end

  private

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :phone_number, :email)
  end
end
