# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Glueby::AR::SystemInformation.synced_block_height.nil?
  Glueby::AR::SystemInformation.create(info_key: 'synced_block_number', info_value: '0')
end

# Generate block to UTXO Provider's address
utxo_provider_address = Glueby::UtxoProvider.instance.address
aggregate_private_key = ENV['TAPYRUS_AUTHORITY_KEY']
Glueby::Internal::RPC.client.generatetoaddress(1, utxo_provider_address, aggregate_private_key)

# Start BlockSyncer
# source: https://github.com/chaintope/glueby/blob/master/lib/tasks/glueby/block_syncer.rake#L17
latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end

Glueby::UtxoProvider::Tasks.new.manage_utxo_pool

Glueby::Internal::RPC.client.generatetoaddress(1, utxo_provider_address, aggregate_private_key)

# Start BlockSyncer
# source: https://github.com/chaintope/glueby/blob/master/lib/tasks/glueby/block_syncer.rake#L17
latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end

# utxo_provider_wallet = Wallet.find(1)
glueby_wallet_id = Glueby::UtxoProvider.instance.wallet.id
utxo_provider_wallet = Wallet.find_or_create_by!(glueby_wallet_id:)

return if Token.find_by(id: 1).present?

token, = Glueby::Contract::Token.issue!(
  issuer: utxo_provider_wallet.glueby_wallet,
  token_type: Tapyrus::Color::TokenTypes::REISSUABLE,
  amount: 1
)

Glueby::Internal::RPC.client.generatetoaddress(1, utxo_provider_address, aggregate_private_key)

# Start BlockSyncer
# source: https://github.com/chaintope/glueby/blob/master/lib/tasks/glueby/block_syncer.rake#L17
latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end

token.burn!(sender: utxo_provider_wallet.glueby_wallet, amount: 1)

Glueby::Internal::RPC.client.generatetoaddress(1, utxo_provider_address, aggregate_private_key)

latest_block_num = Glueby::Internal::RPC.client.getblockcount
synced_block = Glueby::AR::SystemInformation.synced_block_height
(synced_block.int_value + 1..latest_block_num).each do |height|
  Glueby::BlockSyncer.new(height).run
  synced_block.update(info_value: height.to_s)
end

Token.create!(script_pubkey_payload_hex: token.script_pubkey.to_payload.bth)
