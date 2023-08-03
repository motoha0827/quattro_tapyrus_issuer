# frozen_string_literal: true

Tapyrus.chain_params = :dev if ENV['TAPYRUS_CHAIN_PARAMS'] == 'dev'

Glueby.configure do |config|
  config.rpc_config = {
    schema: 'http',
    host: ENV['TAPYRUS_RPC_HOST'],
    port: ENV['TAPYRUS_RPC_PORT'],
    user: ENV['TAPYRUS_RPC_USER'],
    password: ENV['TAPYRUS_RPC_PASSWORD']
  }

  # Use ActiveRecord as wallet adapter
  config.wallet_adapter = :activerecord

  # ここで SystemInfomation がなければ作るべき？

  # Use UTXO Provider
  config.enable_utxo_provider!
  config.utxo_provider_config = {
    # The amount that each utxo in utxo pool posses.
    default_value: 20_000,
    # The number of utxos in utxo pool. This size should not be greater than 2000.
    utxo_pool_size: 100
  }
end
