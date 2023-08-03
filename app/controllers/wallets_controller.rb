# frozen_string_literal: true

class WalletsController < ApplicationController
  before_action :signed_in?, only: %i[show new create]
  before_action :has_wallet?, only: %i[show]
  before_action :already_has_wallet, only: %i[new create]

  def show
    @wallet = current_user.wallet
  end

  def new; end

  def create
    current_user.build_wallet.save!
    services_json = {
                     "services": [
                       {
                         "id": 'quattrowallet',
                         "type": 'QuattroWallet',
                         "serviceEndpoint": "https://issuer.quattro.example.com/wallets/#{current_user.wallet.id}"
                       }
                     ]
                   }.to_json

    response = Net::HTTP.post(
      URI('http://localhost:3001/did/create'),
      services_json,
      'Content-Type' => 'application/json'
    )
    body = JSON.parse(response.body)
    did_long_form = body['did']
    signing_key = body['singingKey']
    recovery_key = body['recoveryKey']
    update_key = body['updateKey']

    Did.create!(did_long_form:, signing_key:, recovery_key:, update_key:)

    redirect_to wallet_path
  end

  def deposit_new; end

  def deposit
    amount = params[:wallet][:amount].to_i
    account = current_user.account
    Token.instance.reissue!(amount:)
    generate_block
    Token.instance.transfer!(sender: Wallet.utxo_provider_wallet, receiver: current_user.wallet, amount:)
    generate_block
    account.update!(balance: account.balance - amount)

    redirect_to user_path, notice: "Deposit successful."
  end

  def withdraw_new; end

  def withdraw
    amount = params[:wallet][:amount].to_i
    account = current_user.account
    Token.instance.burn!(wallet: current_user.wallet, amount:)
    generate_block
    account.update!(balance: account.balance + amount)

    redirect_to user_path, notice: "Deposit successful."
  end

  private

  def has_wallet?
    redirect_to new_wallet_path unless current_user.wallet
  end

  def already_has_wallet
    redirect_to wallet_path if current_user.wallet
  end

  def generate_block
    utxo_provider_address = Glueby::UtxoProvider.instance.address
    aggregate_private_key = ENV['TAPYRUS_AUTHORITY_KEY']
    Glueby::Internal::RPC.client.generatetoaddress(1, utxo_provider_address, aggregate_private_key)

    latest_block_num = Glueby::Internal::RPC.client.getblockcount
    synced_block = Glueby::AR::SystemInformation.synced_block_height
    (synced_block.int_value + 1..latest_block_num).each do |height|
      Glueby::BlockSyncer.new(height).run
      synced_block.update(info_value: height.to_s)
    end
  end
end
