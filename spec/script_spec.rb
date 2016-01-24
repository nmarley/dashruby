require_relative 'spec_helper'
describe Dash::Script do
  
  it "should instantiate with empty data" do
    empty_script = Dash::Script.new
    empty_script.data.must_equal "".b
    empty_script.to_s.must_equal ''
  end

  it "should support standard P2PKH script" do
    script = (Dash::Script.new << Dash::OP_DUP << Dash::OP_HASH160 << "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG)
    script.standard?.must_equal true
    script.public_key_hash_script?.must_equal true
    script.script_hash_script?.must_equal false
    script.multisig_script?.must_equal false
    script.standard_multisig_script?.must_equal false
    script.standard_address.class.must_equal Dash::PublicKeyAddress
    script.standard_address.data.must_equal "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex
    script.to_s.must_equal "OP_DUP OP_HASH160 5a73e920b7836c74f9e740a5bb885e8580557038 OP_EQUALVERIFY OP_CHECKSIG"
  end

  it "should support standard P2SH script" do
    script = (Dash::Script.new << Dash::OP_HASH160 << "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex << Dash::OP_EQUAL)
    script.standard?.must_equal true
    script.public_key_hash_script?.must_equal false
    script.script_hash_script?.must_equal true
    script.multisig_script?.must_equal false
    script.standard_multisig_script?.must_equal false
    script.standard_address.class.must_equal Dash::ScriptHashAddress
    script.standard_address.data.must_equal "5a73e920b7836c74f9e740a5bb885e8580557038".from_hex
    script.to_s.must_equal "OP_HASH160 5a73e920b7836c74f9e740a5bb885e8580557038 OP_EQUAL"
  end

  it "should support standard multisig script" do
    script = (Dash::Script.new << Dash::OP_1 <<
              "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex <<
              "bffbec99da8a6573bd4e359d85c8cb62e6f483d9afac4be2db963f0fe10bcb19".from_hex <<
              Dash::OP_2 <<
              Dash::OP_CHECKMULTISIG)
    script.standard?.must_equal true
    script.public_key_hash_script?.must_equal false
    script.script_hash_script?.must_equal false
    script.multisig_script?.must_equal true
    script.standard_multisig_script?.must_equal true
    script.standard_address.must_equal nil
    script.multisig_public_keys.must_equal [
      "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex,
      "bffbec99da8a6573bd4e359d85c8cb62e6f483d9afac4be2db963f0fe10bcb19".from_hex
    ]
    script.multisig_signatures_required.must_equal 1
    script.to_s.must_equal "OP_1 c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a "+
                           "bffbec99da8a6573bd4e359d85c8cb62e6f483d9afac4be2db963f0fe10bcb19 OP_2 OP_CHECKMULTISIG"

    script2 = Dash::Script.multisig(public_keys:[
                             "c4bbcb1fbec99d65bf59d85c8cb62ee2db963f0fe106f483d9afa73bd4e39a8a".from_hex,
                             "bffbec99da8a6573bd4e359d85c8cb62e6f483d9afac4be2db963f0fe10bcb19".from_hex
                           ], signatures_required: 1)

    script2.standard_multisig_script?.must_equal true
    script.must_equal script2


  end

  it "should support subscripts" do
    s = Dash::Script.new << Dash::OP_DUP << Dash::OP_HASH160 << Dash::OP_CODESEPARATOR << "some data" << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG
    s.subscript(0..-1).must_equal s
    s[0..-1].must_equal s
    s.subscript(3..-1).must_equal(Dash::Script.new << "some data" << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG)
    s[3..-1].must_equal(Dash::Script.new << "some data" << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG)
  end


  it "removing subscript does not modify the receiver" do
    s = Dash::Script.new << Dash::OP_DUP << Dash::OP_HASH160 << Dash::OP_CODESEPARATOR << "some data" << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG
    s1 = s.dup
    s2 = s1.find_and_delete(Dash::Script.new << Dash::OP_HASH160)
    s.must_equal s1
    s2.must_equal(Dash::Script.new << Dash::OP_DUP << Dash::OP_CODESEPARATOR << "some data" << Dash::OP_EQUALVERIFY << Dash::OP_CHECKSIG)
  end

  it "should find subsequence" do
    s = Dash::Script.new << Dash::OP_1 << Dash::OP_3 << Dash::OP_1 << Dash::OP_2 << Dash::OP_1 << Dash::OP_2 << Dash::OP_1 << Dash::OP_3
    s2 = s.find_and_delete(Dash::Script.new << Dash::OP_1 << Dash::OP_2 << Dash::OP_1)
    s2.must_equal(Dash::Script.new << Dash::OP_1 << Dash::OP_3 << Dash::OP_2 << Dash::OP_1 << Dash::OP_3)
  end

  it "should not find-and-delete non-matching encoding for the same pushdata" do
    s = Dash::Script.new.append_pushdata("foo").append_pushdata("foo", opcode:Dash::OP_PUSHDATA1)
    s2 = s.find_and_delete(Dash::Script.new << "foo")
    s2.must_equal(Dash::Script.new.append_pushdata("foo", opcode:Dash::OP_PUSHDATA1))
  end

  it "should parse interpreted data and pushdata correctly" do
    script = Dash::Script.new << Dash::OP_0 << Dash::OP_1NEGATE << Dash::OP_NOP << Dash::OP_RESERVED << Dash::OP_1 << Dash::OP_16 << "1" << "2" << "chancellor"
    script.chunks.map{|c| c.interpreted_data }.must_equal ["", "\x81".b, nil, nil, "\x01".b, "\x10".b, "1", "2", "chancellor"]
    script.chunks.map{|c| c.pushdata }.must_equal ["", nil, nil, nil, nil, nil, "1", "2", "chancellor"]
  end

end
