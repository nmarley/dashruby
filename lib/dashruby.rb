
require 'ffi' # gem install ffi

# Tip: import 'dashruby/extensions' to enable extensions to standard classes (e.g. String#to_hex)
# Extensions are not imported by default to avoid conflicts with other libraries.

require_relative 'dashruby/version.rb'
require_relative 'dashruby/errors.rb'
require_relative 'dashruby/diagnostics.rb'
require_relative 'dashruby/safety.rb'
require_relative 'dashruby/hash_functions.rb'
require_relative 'dashruby/data.rb'
require_relative 'dashruby/openssl.rb'
require_relative 'dashruby/big_number.rb'
require_relative 'dashruby/base58.rb'

require_relative 'dashruby/constants.rb'
require_relative 'dashruby/script/opcode.rb'
require_relative 'dashruby/currency_formatter.rb'
require_relative 'dashruby/network.rb'
require_relative 'dashruby/address.rb'
require_relative 'dashruby/wif.rb'
require_relative 'dashruby/key.rb'
require_relative 'dashruby/keychain.rb'
require_relative 'dashruby/mnemonic.rb'
require_relative 'dashruby/wire_format.rb'
require_relative 'dashruby/hash_id.rb'
require_relative 'dashruby/outpoint.rb'
require_relative 'dashruby/transaction.rb'
require_relative 'dashruby/transaction_input.rb'
require_relative 'dashruby/transaction_output.rb'
require_relative 'dashruby/validation.rb'

require_relative 'dashruby/script/script_error.rb'
require_relative 'dashruby/script/script_flags.rb'
require_relative 'dashruby/script/script_number.rb'
require_relative 'dashruby/script/script_chunk.rb'
require_relative 'dashruby/script/script.rb'
require_relative 'dashruby/script/script_interpreter.rb'
require_relative 'dashruby/script/signature_hashtype.rb'
require_relative 'dashruby/script/signature_checker.rb'
require_relative 'dashruby/script/test_signature_checker.rb'
require_relative 'dashruby/script/transaction_signature_checker.rb'

require_relative 'dashruby/script/script_interpreter_extension.rb'
require_relative 'dashruby/script/p2sh_extension.rb'
require_relative 'dashruby/script/cltv_extension.rb'

require_relative 'dashruby/transaction_builder.rb'
require_relative 'dashruby/proof_of_work.rb'
require_relative 'dashruby/block_header.rb'
require_relative 'dashruby/block.rb'
require_relative 'dashruby/merkle_tree.rb'
require_relative 'dashruby/ssss.rb'

# TODO:
# require_relative 'dashruby/curve_point.rb'
# require_relative 'dashruby/script_machine.rb'
# require_relative 'dashruby/merkle_block.rb'
# require_relative 'dashruby/bloom_filter.rb'
# require_relative 'dashruby/processor.rb'
