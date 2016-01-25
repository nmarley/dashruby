# Using an Electrum mnemonic seed
# -------------------------------
#
# This example demonstrates how to use a 13-word seed from Electrum

require_relative "../lib/dashruby.rb"

words = 'grass become field hedgehog chimney offer bridge crash decide that milk today about'
mnemonic = Dash::Mnemonic.new(words: words)

keychain = Dash::Keychain.new(seed: mnemonic.electrum_seed)

puts keychain.xpub # extended public key
# => drkvjJe5sJgqomjLnbHodt6fvgTUGNs8Bi8AVRyXcGicp3KqadgpCDLYMA8dHzJiTHnhBJDH9rrWfh2Eu6wNyYDMY7qrpTyjn3iEecLHWaf9yE6

puts keychain.xprv # extended private key
# => drkpRsmwKURS9g8uDPKZ2ULrCm4mWcwauRbjKtFaGUtNvsdfLM1SWf5eWawgz2Lv6tGRPuh5fj6rezKA1BQhhsdN3yKQEg2N1TRSz9XTaZR7tcP

puts keychain.derived_key('0/0').address.to_s # 1st Electrum standard address
# => XbSdniGiXmoFdC6Ptws4K7TjPv3hn6Yhy1

puts keychain.derived_key('0/1').address.to_s # 2nd Electrum standard address...
# => XeRZm9fn47rfC5ZP9SAoYVnHr6BRHpudtU

puts keychain.derived_key('1/0').address.to_s # 1st Electrum change address...
# => Xni7Lc1wzQkN6jrxN5J5PeUwECC2Afe7zd

