require_relative 'spec_helper'
describe Dash::Address do

  it "should decode/encode mainnet pay-to-pubkey-hash address" do
    address = Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ")
    address.is_a?(Dash::PublicKeyAddress).must_equal(true)

    address.mainnet?.must_equal true
    address.testnet?.must_equal false
    address.p2sh?.must_equal    false
    address.p2pkh?.must_equal   true

    address.data.must_equal "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex

    address = Dash::PublicKeyAddress.new(hash: "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex)

    address.script.to_s.must_equal "OP_DUP OP_HASH160 5a73e920b7836c74f9e740a5bb885e8580557038 OP_EQUALVERIFY OP_CHECKSIG"

    address.to_s.must_equal("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ")
    address.data.must_equal(Dash.from_hex("5a73e920b7836c74f9e740a5bb885e8580557038"))
  end

  it "should decode/encode testnet pay-to-pubkey-hash address" do

    address = Dash::Address.parse("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn")
    address.is_a?(Dash::PublicKeyAddress).must_equal true

    address.mainnet?.must_equal false
    address.testnet?.must_equal true
    address.p2sh?.must_equal    false
    address.p2pkh?.must_equal   true

    address.data.must_equal "243f1394f44554f4ce3fd68649c19adc483ce924".from_hex

    address2 = Dash::PublicKeyAddress.new(hash: "243f1394f44554f4ce3fd68649c19adc483ce924".from_hex, network: Dash::Network.testnet)

    address2.to_s.must_equal("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn")
    address2.data.must_equal("243f1394f44554f4ce3fd68649c19adc483ce924".from_hex)
  end

  it "should detect invalid pay-to-pubkey-hash address" do
    lambda { Dash::Address.parse(nil) }.must_raise ArgumentError
    lambda { Dash::Address.parse("") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("18FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDvwq") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RD") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRf") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("m") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("mipc") }.must_raise Dash::FormatError
  end

  it "should decode/encode mainnet pay-to-script-hash address" do

    address = Dash::Address.parse("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX")
    address.is_a?(Dash::ScriptHashAddress).must_equal(true)

    address.mainnet?.must_equal true
    address.testnet?.must_equal false
    address.p2sh?.must_equal    true
    address.p2pkh?.must_equal   false

    address.data.must_equal "8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex
    address.hash.must_equal "8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex

    address = Dash::ScriptHashAddress.new(hash: "8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex)

    address.script.to_s.must_equal "OP_HASH160 8f55563b9a19f321c211e9b9f38cdf686ea07845 OP_EQUAL"

    address.to_s.must_equal("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX")
    address.data.must_equal("8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex)
  end

  it "should decode/encode testnet pay-to-script-hash address" do

    address = Dash::Address.parse("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX")
    address.is_a?(Dash::ScriptHashAddress).must_equal(true)

    address.mainnet?.must_equal true
    address.testnet?.must_equal false
    address.p2sh?.must_equal    true
    address.p2pkh?.must_equal   false

    address.data.must_equal "8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex

    address = Dash::ScriptHashAddress.new(hash: "8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex)

    address.to_s.must_equal("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX")
    address.data.must_equal("8f55563b9a19f321c211e9b9f38cdf686ea07845".from_hex)
  end

  it "should detect invalid pay-to-script-hash address" do
    lambda { Dash::Address.parse("3ektnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzqX") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSg") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("2mzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1Vc") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJa1vc") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("2MzQwSSnBHWHqSAqtTVQ6v47XtaisrJ") }.must_raise Dash::FormatError
  end


  it "should decode/encode private key string with uncompressed pubkey" do

    address = Dash::Address.parse("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS")
    address.is_a?(Dash::WIF).must_equal(true)

    address.public_key_compressed?.must_equal false
    address.mainnet?.must_equal true
    address.testnet?.must_equal false
    address.p2sh?.must_equal    false
    address.p2pkh?.must_equal   false

    address.data.must_equal "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex

    address = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex)

    address.to_s.must_equal("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS")
    address.data.must_equal("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex)

  end

  it "should decode/encode private key string with compressed pubkey" do

    address = Dash::Address.parse("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu")
    address.is_a?(Dash::WIF).must_equal(true)

    address.public_key_compressed?.must_equal true
    address.mainnet?.must_equal true
    address.testnet?.must_equal false
    address.p2sh?.must_equal    false
    address.p2pkh?.must_equal   false

    address.data.must_equal "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex

    address = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex, public_key_compressed: true)

    address.to_s.must_equal("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu")
    address.data.must_equal("c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex)

  end

  it "should detect invalid private key address" do
    lambda { Dash::Address.parse("5kJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hS") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZXj3hs") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("5KJvsngHeMpm884wtkJNzQGaCErckhHJBGFsvd3VyK5qMZ") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("L3P8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSU") }.must_raise Dash::FormatError
    lambda { Dash::Address.parse("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJ") }.must_raise Dash::FormatError
  end

  it "should convert strings and addresses into normalized address" do
    Dash::Address.parse(Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ")).class.must_equal Dash::PublicKeyAddress
    Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ").class.must_equal Dash::PublicKeyAddress
    ->{ Dash::Address.parse(nil) }.must_raise ArgumentError
  end

  it "should convert any address to a public_address" do
    a1 = Dash::Address.parse("1C7zdTfnkzmr13HfA2vNm5SJYRK6nEKyq8")
    a1.public_address.must_equal a1

    a2 = Dash::Address.parse("L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu")
    a2.public_address.must_equal a1

    a3 = Dash::Address.parse("3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX")
    a3.public_address.must_equal a3
  end

  it "should support equality" do
    address1  = Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ")
    address2  = Dash::PublicKeyAddress.new(hash: "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex)
    address3  = Dash::PublicKeyAddress.new(hash: "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex, network: Dash::Network.testnet)
    address4  = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex, public_key_compressed: true)
    address41 = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex, public_key_compressed: true)
    address5  = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex, public_key_compressed: false)
    address51 = Dash::WIF.new(private_key: "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex, public_key_compressed: false)

    (address1 == address2).must_equal true
    (address2 == address1).must_equal true
    (address1 == address3).must_equal false
    (address2 == address3).must_equal false

    (address1 == address4).must_equal false
    (address2 == address4).must_equal false
    (address3 == address4).must_equal false
    (address5 == address4).must_equal false
    (address4 == address5).must_equal false

    (address4 == address41).must_equal true
    (address5 == address51).must_equal true
  end

end


