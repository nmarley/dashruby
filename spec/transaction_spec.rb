require_relative 'spec_helper'
require_relative 'data/tx_valid'
require_relative 'data/tx_invalid'

describe Dash::Transaction do

  it "should have core attributes" do

    tx = Dash::Transaction.new

    tx.data.to_hex.must_equal("01000000" + "0000" + "00000000")

    tx.to_h.must_equal({
      "hash"=>"d21633ba23f70118185227be58a63527675641ad37967e2aa461559f577aec43",
      "ver"=>1,
      "vin_sz"=>0,
      "vout_sz"=>0,
      "lock_time"=>0,
      "size"=>10,
      "in"=>[],
      "out"=>[]
    })

  end
  
  describe "Bitcoin Core test vectors" do
    
    module TxTestHelper
      extend self
      
      # Read tests from test/data/tx_valid.json
      # Format is an array of arrays
      # Inner arrays are either [ "comment" ]
      # or [[[prevout hash, prevout index, prevout scriptPubKey], [input 2], ...],"], serializedTransaction, verifyFlags
      # ... where all scripts are stringified scripts.
      #
      # verifyFlags is a comma separated list of script verification flags to apply, or "NONE"
      def parse_tests(records, expected_result)
        comment = nil
        records.each do |test|
          if test[0].is_a?(Array)
            if test.size != 3 || !test[1].is_a?(String) || !test[2].is_a?(String)
              raise "Bad test: #{test.inspect} (#{test.size} #{test[1].class} #{test[2].class})"
            end
            mapprevOutScriptPubKeys = {} # Outpoint => Script
            inputs = test[0]
            inputs.each do |input|
              raise "Bad test: input is not an array: #{test.inspect}" if !input.is_a?(Array)
              raise "Bad test: input is an array of 3 items: #{test.inspect}" if input.size != 3
              previd, previndex, scriptstring = input
            
              outpoint = Dash::Outpoint.new(transaction_id: previd, index: previndex)
            
              mapprevOutScriptPubKeys[outpoint] = parse_script(scriptstring)
            end
          
            tx = Dash::Transaction.new(hex: test[1])
            flags = parse_flags(test[2])
            
            if debug_filter(test)
              validation_proc = lambda do
                validation_passed = Dash::Validation.new.check_transaction(tx, Dash::ValidationState.new)
                if expected_result
                  validation_passed.must_equal expected_result
                end
                script_passed = false
              
                if validation_passed
                  tx.inputs.each do |txin|
                    output_script = mapprevOutScriptPubKeys[txin.outpoint]
                    raise "Bad test: output script not found: #{test.inspect}" if !output_script
                    sig_script = txin.signature_script
                    if !sig_script
                      sig_script = Dash::Script.new(data: txin.coinbase_data)
                    end
                    
                    checker = Dash::TransactionSignatureChecker.new(transaction: tx, input_index: txin.index)
                    extensions = []
                    extensions << Dash::P2SHExtension.new if (flags & Dash::ScriptFlags::SCRIPT_VERIFY_P2SH) != 0
                    extensions << Dash::CLTVExtension.new if (flags & Dash::ScriptFlags::SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY) != 0
                    interpreter = Dash::ScriptInterpreter.new(
                      flags: flags,
                      extensions: extensions,
                      signature_checker: checker,
                      raise_on_failure: expected_result,
                    )
                    #Diagnostics.current.trace do
                      script_passed = interpreter.verify_script(signature_script: sig_script, output_script: output_script)
                      if !script_passed
                        break
                      end
                    #end
                  end
                end
                (script_passed && validation_passed).must_equal expected_result
              end # proc
              
              yield(comment || test.inspect, validation_proc)
            end # if not filtered
            
            comment = nil
          else
            comment ||= ""
            comment += test[0].gsub(/\.$/,"") + ". "
            comment.gsub!(/\. $/, "")
          end
        end
      end
      
      def debug_filter(test)
        
        #return test.inspect[%{010000000200010000000000000000000000000000000000000000000000000000000000000000000000ffffffff00020000000000000000000000000000000000000000000000000000000000000100000000000000000100000000000000000000000000}]
        
        
        # !!! SIGHASH_SINGLE tx: afd9c17f8913577ec3509520bd6e5d63e9c0fd2a5f70c787993b097ba6ca9fae hashed for input 0: 1eccdc1f7a4783924a49113b491a847de2f89a1e7d73b1ae561d80f918035f46
        # !!! SIGHASH_SINGLE tx: afd9c17f8913577ec3509520bd6e5d63e9c0fd2a5f70c787993b097ba6ca9fae hashed for input 1: 1943e87af64d0bde608a85330f09aa5c9887a4fdfd9ca6d7a139bef27fee8e3b
        # !!! SIGHASH_SINGLE tx: afd9c17f8913577ec3509520bd6e5d63e9c0fd2a5f70c787993b097ba6ca9fae hashed for input 2: 1c1f068da6a721f2ecb0fdac3b8adcb4073fee34506971472d29d305507894d6
        #return test.inspect[%{DUP HASH160 0x14 0xdcf72c4fd02f5a987cf9b02f2fabfcac3341a87d EQUALVERIFY CHECKSIG}]
        
        #return test.inspect[%{[[["60a20bd93aa49ab4b28d514ec10b06e1829ce6818ec06cd3aabd013ebcdc4bb1", 0, "1 0x41 0x04cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4 0x41 0x0461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af 2 OP_CHECKMULTISIG"]], "0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000", "P2SH"]}]
        true
      end
      
      # def verify_script(tx, txin, sig_script, output_script, flags, expected_result, record)
      #   checker = TransactionSignatureChecker.new(transaction: tx, input_index: txin.index)
      #   extensions = []
      #   extensions << P2SHExtension.new if (flags & ScriptFlags::SCRIPT_VERIFY_P2SH) != 0
      #   extensions << CLTVExtension.new if (flags & ScriptFlags::SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY) != 0
      #   interpreter = ScriptInterpreter.new(
      #     flags: flags,
      #     extensions: extensions,
      #     signature_checker: checker,
      #     raise_on_failure: expected_result,
      #   )
      #   #Diagnostics.current.trace do
      #     checked = Validation.new.check_transaction(tx, ValidationState.new)
      #     if expected_result
      #       checked.must_equal expected_result
      #     end
      #     result = false
      #     if checked
      #       result = interpreter.verify_script(signature_script: sig_script, output_script: output_script)
      #       if result != expected_result
      #         # puts "Failed scripts: #{sig_script.to_s.inspect} #{output_script.to_s.inspect} flags #{flags}, expected to #{expected_result ? 'succeed' : 'fail'}".gsub(/OP_/, "")
      #         # puts "Error: #{interpreter.error.inspect}"
      #         #debug("Failed #{expected_result ? 'valid' : 'invalid'} script: #{sig_script.to_s.inspect} #{output_script.to_s.inspect} flags #{flags} -- #{record.inspect}")
      #       end
      #     end
      #     puts
      #     puts record.inspect
      #     puts "---------------------------" 
      #     puts (result && checked).inspect
      #     puts
      #     (result && checked).must_equal expected_result
      #   #end
      # end
      
      
    end
    
    TxTestHelper.parse_tests(ValidTxs, true) do |comment, validation_proc|
      it "should validate transaction: #{comment}" do
        validation_proc.call
        #TxTestHelper.verify_script(tx, txin, signature_script, output_script, flags, expected_result, record)
      end
    end
    
    TxTestHelper.parse_tests(InvalidTxs, false) do |comment, validation_proc| # |helper, tx, txin, signature_script, output_script, flags, expected_result, record, comment|
      it "should fail transaction: #{comment}" do
        validation_proc.call
        #TxTestHelper.verify_script(tx, txin, signature_script, output_script, flags, expected_result, record)
      end
    end
  end

  describe "Hash <-> ID conversion" do
    before do
      @txid   = "43ec7a579f5561a42a7e9637ad4156672735a658be2752181801f723ba3316d2"
      @txhash = @txid.from_hex.reverse
    end

    it "should convert tx ID to binary hash" do
      Dash.hash_from_id(nil).must_equal nil
      Dash.hash_from_id(@txid).must_equal @txhash
    end

    it "should convert binary hash to tx ID" do
      Dash.id_from_hash(nil).must_equal nil
      Dash.id_from_hash(@txhash).must_equal @txid
    end

    it "should convert hash to/from id for TransactionOutput" do
      txout = Dash::TransactionOutput.new
      txout.transaction_hash = @txhash
      txout.transaction_id.must_equal @txid
      txout.transaction_id = "deadbeef"
      txout.transaction_hash.to_hex.must_equal "efbeadde"
    end
  end


  describe "Amounts calculation" do
    before do
      @tx = Dash::Transaction.new
      @tx.add_input(Dash::TransactionInput.new)
      @tx.add_input(Dash::TransactionInput.new)
      @tx.add_output(Dash::TransactionOutput.new(value: 123))
      @tx.add_output(Dash::TransactionOutput.new(value: 50_000))
    end

    it "should have good defaults" do
      @tx.inputs_amount.must_equal nil
      @tx.fee.must_equal nil
      @tx.outputs_amount.must_equal 50_123
    end

    it "should derive inputs_amount from fee" do
      @tx.fee = 10_000
      @tx.fee.must_equal 10_000
      @tx.inputs_amount.must_equal 60_123
      @tx.outputs_amount.must_equal 50_123
    end

    it "should derive fee from inputs_amount" do
      @tx.inputs_amount = 55_123
      @tx.fee.must_equal 5_000
      @tx.inputs_amount.must_equal 55_123
      @tx.outputs_amount.must_equal 50_123
    end

    it "should derive inputs_amount from input values if present" do
      @tx.inputs[0].value = 50_523
      @tx.inputs[1].value = 100
      @tx.fee.must_equal 500
      @tx.inputs_amount.must_equal 50_623
      @tx.outputs_amount.must_equal 50_123
    end

    it "should not derive inputs_amount from input values if some value is nil" do
      @tx.inputs[0].value = 50_523
      @tx.inputs[1].value = nil
      @tx.fee.must_equal nil
      @tx.inputs_amount.must_equal nil
      @tx.outputs_amount.must_equal 50_123
    end
  end


  describe "Certain transaction" do

    before do
      @txdata =("0100000001dfb32e172d6cdc51215c28b83415f977fc6ce281e057f7cf40c700" +
                "8003f7230f000000008a47304402207f5561ac3cfb05743cab6ca914f7eb93c4" +
                "89f276f10cdf4549e7f0b0ef4e85cd02200191c0c2fd10f10158973a0344fdaf" +
                "2438390e083a509d2870bcf2b05445612b0141043304596050ca119efccada1d" +
                "d7ca8e511a76d8e1ddb7ad050298d208455b8bcd09593d823ca252355bf0b41c" +
                "2ac0ba2afa7ada4660bd38e27585aac7d4e6e435ffffffff02c0791817000000" +
                "0017a914bd224370f93a2b0435ded92c7f609e71992008fc87ac7b4d1d000000" +
                "001976a914450c22770eebb00d376edabe7bb548aa64aa235688ac00000000").from_hex
      @tx = Dash::Transaction.new(hex: @txdata.to_hex)
      @tx = Dash::Transaction.new(data: @txdata)
    end

    it "should decode inputs and outputs correctly" do
      @tx.version.must_equal 1
      @tx.lock_time.must_equal 0
      @tx.inputs.size.must_equal 1
      @tx.outputs.size.must_equal 2
      @tx.transaction_id.must_equal "f2d0daf07409e44216fe71075df88f3c8c0c5f8e313582ab256e7af2765dd14e"
    end

    it "should support dup" do
      @tx2 = @tx.dup
      @tx2.data.must_equal @txdata
      @tx2.must_equal @tx
      @tx2.object_id.wont_equal @tx.object_id
    end

    it "detect script kinds" do
      @tx.outputs[0].script.standard?.must_equal true
      @tx.outputs[0].script.script_hash_script?.must_equal true

      @tx.outputs[1].script.standard?.must_equal true
      @tx.outputs[1].script.public_key_hash_script?.must_equal true
    end

    it "input script should have a valid signature" do

      @tx.inputs.first.signature_script.to_a.map{|c|c.to_hex}.must_equal [
        "304402207f5561ac3cfb05743cab6ca914f7eb93c489f276f10cdf4549e7f0b0ef4e85cd02200191c0c2fd10f10158973a0344fdaf2438390e083a509d2870bcf2b05445612b01",
        "043304596050ca119efccada1dd7ca8e511a76d8e1ddb7ad050298d208455b8bcd09593d823ca252355bf0b41c2ac0ba2afa7ada4660bd38e27585aac7d4e6e435"
      ]

      Dash::Diagnostics.current.trace do
        Dash::Key.validate_script_signature(@tx.inputs.first.signature_script.to_a[0], verify_lower_s: true).must_equal true
      end
    end

  end

  describe "Coinbase Transaction" do
    before do
      @txdata =("0100000001000000000000000000000000000000000000000000000000000000" +
                "0000000000ffffffff130301e6040654188d181202119700de00000fccffffff" +
                "ff0108230595000000001976a914ca6ecc7d4d671d8c5c964a48dbb0bc194407" +
                "a30688ac00000000").from_hex
      @tx = Dash::Transaction.new(data: @txdata)
    end

    it "should encode coinbase inputs correctly" do
      @tx.data.must_equal @txdata
    end
  end

end
