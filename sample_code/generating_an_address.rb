# Generating an address
# ---------------------
#
# This example demonstrates how to generate a key and get its address.

require_relative "../lib/dashruby.rb"

key = Dash::Key.random

puts key.to_wif # private key in WIF format
# => L4RqZhbn2VsVgy2wCWW8kUPpA4xEkH7WbfPtj1MdFug5MayHzLeT

puts key.address.to_s # public address
# => 1MFqAcAxNsAKj5e6yksZCCyfNukSdDGsEY

puts key.to_wif(network: Dash::Network.testnet)
# => cUnq2cbdTZZkrQWCavKG7ntsnJFeQjDCfhYMqRp8m2L5cL1yHDmc

puts key.address(network: Dash::Network.testnet).to_s
# => n1mnTfFwBtbaWC7ihKqw28BzEuM9YqxRyw