# frozen_string_literal: true

# ウォレットモデル
class Wallet < ApplicationRecord
  validates :glueby_wallet_id, presence: true

  belongs_to :user, optional: true
  has_one :did

  after_initialize do
    self.glueby_wallet_id ||= Glueby::Wallet.create.id
  end

  def self.utxo_provider_wallet
    find_by(glueby_wallet_id: 'UTXO_PROVIDER_WALLET')
  end

  def balance
    Token.instance.glueby_token.amount(wallet: glueby_wallet)
  end

  def glueby_wallet
    @glueby_wallet ||= Glueby::Wallet.load(glueby_wallet_id)
  end
end
