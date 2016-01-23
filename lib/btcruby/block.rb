module BTC
  # Nodes collect new transactions into a block, hash them into a hash tree,
  # and scan through nonce values to make the block's hash satisfy proof-of-work
  # requirements.  When they solve the proof-of-work, they broadcast the block
  # to everyone and the block is added to the block chain.  The first transaction
  # in the block is a special one that creates a new coin owned by the creator
  # of the block.
  class Block < BlockHeader

    # Array of BTC::Transaction objects
    attr_accessor :transactions

    def self.genesis_mainnet
      self.new(
        version:             1,
        previous_block_hash: ZERO_HASH256,
        merkle_root:         BTC.from_hex("c762a6567f3cc092f0684bb62b7e00a84890b990f07cc71a6bb58d64b98e02e0"),
        timestamp:           1390095618,
        bits:                0x1e0ffff0,
        nonce:               0x1b93fc2,
        transactions:        [BTC::Transaction.new(
          version:   1,
          inputs:    [
            BTC::TransactionInput.new(
              coinbase_data: BTC.from_hex("04FFFF001D01044C595769726564" +
              "2030392F4A616E2F3230313420546865204772616E64204578706572" +
              "696D656E7420476F6573204C6976653A204F76657273746F636B2E63" +
              "6F6D204973204E6F7720416363657074696E6720426974636F696E73"),
            )
          ],
          outputs:   [
            BTC::TransactionOutput.new(
              value: 50*COIN,
              script: Script.new(data: BTC.from_hex("41040184710FA689AD" +
              "5023690C80F3A49C8F13F8D45B8C857FBCBC8BC4A8E4D3EB4B10F4D4" +
              "604FA08DCE601AAF0F470216FE1B51850B4ACF21B179C45070AC7B03" +
              "A9AC"))
            )
          ],
          lock_time: 0
        )],
        height: 0
      )
    end

    def self.genesis_testnet
      self.new(
        version:             1,
        previous_block_hash: ZERO_HASH256,
        merkle_root:         BTC.from_hex("c762a6567f3cc092f0684bb62b7e00a84890b990f07cc71a6bb58d64b98e02e0"),
        timestamp:           1390666206,
        bits:                0x1e0ffff0,
        nonce:               0xe627c9c3,
        transactions:        [BTC::Transaction.new(
          version:   1,
          inputs:    [
            BTC::TransactionInput.new(
              coinbase_data: BTC.from_hex("04FFFF001D01044C595769726564" +
              "2030392F4A616E2F3230313420546865204772616E64204578706572" +
              "696D656E7420476F6573204C6976653A204F76657273746F636B2E63" +
              "6F6D204973204E6F7720416363657074696E6720426974636F696E73"),
            )
          ],
          outputs:   [
            BTC::TransactionOutput.new(
              value: 50*COIN,
              script: Script.new(data: BTC.from_hex("41040184710FA689AD" +
              "5023690C80F3A49C8F13F8D45B8C857FBCBC8BC4A8E4D3EB4B10F4D4" +
              "604FA08DCE601AAF0F470216FE1B51850B4ACF21B179C45070AC7B03" +
              "A9AC"))
            )
          ],
          lock_time: 0
        )],
        height: 0
      )
    end

    def initialize(data: nil,
                   stream: nil,
                   version: CURRENT_VERSION,
                   previous_block_hash: nil,
                   previous_block_id: nil,
                   merkle_root: nil,
                   timestamp: 0,
                   time: nil,
                   bits: 0,
                   nonce: 0,
                   transactions: nil,

                   # optional attributes
                   height: nil,
                   confirmations: nil)
      super(
                       data: data,
                     stream: stream,
                    version: version,
        previous_block_hash: previous_block_hash,
          previous_block_id: previous_block_id,
                merkle_root: merkle_root,
                  timestamp: timestamp,
                       time: time,
                       bits: bits,
                      nonce: nonce,
                     height: height,
              confirmations: confirmations
      )

      @transactions = transactions if transactions
      @transactions ||= []
    end

    def init_with_stream(stream)
      super(stream)
      if !(txs_count = BTC::WireFormat.read_varint(stream: stream).first)
        raise ArgumentError, "Failed to read count of transactions from the stream."
      end
      txs = (0...txs_count).map do
        Transaction.new(stream: stream)
      end
      @transactions = txs
    end

    def data
      data = super
      data << BTC::WireFormat.encode_varint(self.transactions.size)
      self.transactions.each do |tx|
        data << tx.data
      end
      data
    end

    def block_header
      BlockHeader.new(
        version:             self.version,
        previous_block_hash: self.previous_block_hash,
        merkle_root:         self.merkle_root,
        timestamp:           self.timestamp,
        bits:                self.bits,
        nonce:               self.nonce,
        height:              self.height,
        confirmations:       self.confirmations)
    end

    def ==(other)
      super(other) && @transactions == other.transactions
    end

    def dup
      self.class.new(
        version:             self.version,
        previous_block_hash: self.previous_block_hash,
        merkle_root:         self.merkle_root,
        timestamp:           self.timestamp,
        bits:                self.bits,
        nonce:               self.nonce,
        transactions:        self.transactions.map{|t|t.dup},
        height:              self.height,
        confirmations:       self.confirmations)
    end

    def inspect
      %{#<#{self.class.name}:#{self.block_id[0,24]}} +
      %{ ver:#{self.version}} +
      %{ prev:#{self.previous_block_id[0,24]}} +
      %{ merkle_root:#{BTC.id_from_hash(self.merkle_root)[0,16]}} +
      %{ timestamp:#{self.timestamp}} +
      %{ bits:0x#{self.bits.to_s(16)}} +
      %{ nonce:0x#{self.nonce.to_s(16)}} +
      %{ txs(#{self.transactions.size}): #{self.transactions.inspect}} +
      %{>}
    end

  end
end
