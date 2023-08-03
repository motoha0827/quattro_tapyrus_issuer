# frozen_string_literal: true

# サービス内で流通するトークンを管理するモデル
class Token < ApplicationRecord
  validates :script_pubkey_payload_hex, presence: true

  TOKEN_ID = 1 # TODO: .envにでも書きたい

  def self.instance
    find_or_create_by!(id: TOKEN_ID)
  end

  # トークンの再発行
  # UTXO Provider へ渡るため、deposit の際は確定後に transfer が走る
  #
  # @param [Integer|BigInt] amount
  # @return [Tapyrus::Tx] tx
  def reissue!(amount:)
    _, tx = glueby_token.reissue!(issuer: Wallet.utxo_provider_wallet.glueby_wallet, amount:)
    tx
  end

  # トークンの焼却
  #
  # @param [Wallet] wallet
  # @param [Integer|BigInt] amount
  # @return [Tapyrus::Tx] tx
  def burn!(wallet:, amount:)
    glueby_token.burn!(sender: wallet.glueby_wallet, amount:)
  end

  # トークンの移転
  # UTXO を amount: 1 ずつに分割する
  #
  # @param [Wallet] sender
  # @param [Wallet] receiver
  # @param [Integer|BigInt] amount
  # @return [Tapyrus::Tx] tx
  def transfer!(sender:, receiver:, amount:)
    receivers = []
    receive_address = receiver.glueby_wallet.internal_wallet.receive_address
    amount.to_i.times do
      receivers << {
        address: receive_address,
        amount: 1
      }
    end

    # 高額の送金時、稀に min relay fee not met が出るので DEFAULT_FEE = 10_000 を amount に応じて増やしたい
    fee_estimator = Glueby::Contract::FeeEstimator::Fixed.new(fixed_fee: 10_000 * (10**Math.log10(amount.to_i.abs).to_i))

    # UTXO を分割するために multi_transfer! を使う
    _, tx = glueby_token.multi_transfer!(
      sender: sender.glueby_wallet,
      receivers:,
      fee_estimator:
    )

    tx
  end


  # 発行済みトークンの総量
  def total_amount
    tx_outset_info = Glueby::Internal::RPC.client.gettxoutsetinfo
    tx_outset_info['total_amount'][glueby_token.color_id.to_payload.bth]
  end

  # color_id の payload を保存したかったが、Glueby::Contract::Token.parse_from_payload だと ActiveRecord へ保存してしまう。
  # Tapyrus::Color::ColorIdentifier.parse_from_payload してから Token を new すると token_type がずれる。
  # ので script_pubkey を保存することにした。
  def glueby_token
    script_pubkey = Tapyrus::Script.parse_from_payload(script_pubkey_payload_hex.htb)
    color_identifier = Tapyrus::Color::ColorIdentifier.reissuable(script_pubkey)
    Glueby::Contract::Token.new(color_id: color_identifier)
  end
end
