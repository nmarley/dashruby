# Addresses are Base58-encoded pieces of data representing various objects:
#
# 1. Public key hash address. Example: 19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ.
# 2. Private key for uncompressed public key (WIF).
#    Example: 5KQntKuhYWSRXNqp2yhdXzjekYAR7US3MT1715Mbv5CyUKV6hVe.
# 3. Private key for compressed public key (WIF).
#    Example: L3p8oAcQTtuokSCRHQ7i4MhjWc9zornvpJLfmg62sYpLRJF9woSu.
# 4. Script hash address (P2SH). Example: 3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8.
#
# To differentiate between testnet and mainnet, use `network` accessor or `mainnet?`/`testnet?` methods.
#
# To check if the instance of the class is available for
# mainnet or testnet, use mainnet? and testnet? methods respectively.
#
# Usage:
# 1. When receiving an address in Base58 format, convert it to a proper type by doing:
#
#      address = Dash::Address.parse("19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ")
#
# 2. To create an address, use appropriate type and call with_data(binary_data):
#
#      address = Dash::PublicKeyAddress.new(hash: hash)
#
# 3. To convert address to its Base68Check format call to_s:
#
#      string = address.to_s
#
module Dash
  class Address
    include Opcodes
    @@registered_classes = []

    # Decodes address from a Base58Check-encoded string
    def self.parse(string_or_address)
      raise ArgumentError, "Argument is missing" if !string_or_address
      if string_or_address.is_a?(self)
        return string_or_address
      elsif string_or_address.is_a?(Address)
        raise ArgumentError, "Argument must be an instance of #{self}, not #{string_or_address.class}."
      end
      string = string_or_address
      raise ArgumentError, "String is expected" if !string.is_a?(String)
      raw_data = Base58.data_from_base58check(string)
      self.mux_parse_raw_data(raw_data, string)
    end

    # Attempts to parse with a proper subclass
    def self.mux_parse_raw_data(raw_data, _string = nil)
      result = nil
      @@registered_classes.each do |cls|
        if result = cls.parse_raw_data(raw_data, _string)
          break
        end
      end
      if !result
        raise ArgumentError, "Unknown kind of address: #{_string}. Registered types: #{@@registered_classes}"
      end
      if !result.is_a?(self)
        raise ArgumentError, "Argument must be an instance of #{self}, not #{result.class}."
      end
      return result
    end

    # Internal method to parse address from raw binary data.
    # Subclasses should implement to return a valid instance or nil if the provided data does not correspond to that subclass.
    # Default implementation assumes 1-byte version prefix and implementation of mainnet_version and testnet_version class methods.
    def self.parse_raw_data(raw_data, _string = nil)
      raise ArgumentError, "Raw data is missing" if !raw_data
      if raw_data.bytesize < 2 # should contain at least a version byte and some content
        raise FormatError, "Failed to decode Dash::Address: raw data is too short"
      end
      version = raw_data.bytes.first
      if self.mainnet_version == version || self.testnet_version == version
        return self.new(string: _string, _raw_data: raw_data)
      end
      return nil
    end

    # Subclasses should register themselves so they can be parsed via Dash::Address.parse()
    def self.register_class(cls)
      @@registered_classes << cls
    end

    def network
      @network ||= if !@version
        Dash::Network.default
      elsif @version == self.class.mainnet_version
        Dash::Network.mainnet
      else
        Dash::Network.testnet
      end
    end

    def version
      @version ||= if self.network.mainnet?
        self.class.mainnet_version
      else
        self.class.testnet_version
      end
    end

    # Returns binary contents of the address (without version byte and checksum).
    def data
      @data
    end

    # Returns a public version of the address. For public addresses (P2PKH and P2SH) returns self.
    def public_address
      self
    end

    # Two instances are equal when they have the same contents and versions.
    def ==(other)
      return false if !other
      data == other.data && version == other.version
    end
    alias_method :eql?, :==

    def hash
      data.hash
    end

    # Returns Base58Check representation of an address.
    def to_s
      @base58check_string ||= Base58.base58check_from_data(self.data_for_base58check_encoding)
    end

    # Whether this address is usable on mainnet.
    def mainnet?
      self.network.mainnet?
    end

    # Whether this address is usable on testnet.
    def testnet?
      self.network.testnet?
    end

    # Whether this address is pay-to-public-key-hash (classic address which is a hash of a single public key).
    def p2pkh?
      false
    end

    # Whether this address is pay-to-script-hash.
    def p2sh?
      false
    end

    def inspect
      %{#<#{self.class}:#{to_s}>}
    end

    protected

    # Overriden in subclasses to provide concrete version
    def self.mainnet_version
      raise Exception, "Override mainnet_version in your subclass"
    end

    def self.testnet_version
      raise Exception, "Override testnet_version in your subclass"
    end

    # To override in subclasses
    def data_for_base58check_encoding
      raise Exception, "Override data_for_base58check_encoding in #{self.class} to return complete data to be base58-encoded."
    end

    # private
    # def self.version_to_class_dictionary
    #   @version_to_class_dictionary ||= [
    #     PublicKeyAddress,
    #     ScriptHashAddress,
    #     WIF,
    #   ].inject({}) do |dict, cls|
    #     dict[cls.mainnet_version] = cls
    #     dict[cls.testnet_version] = cls
    #     dict
    #   end
    # end
  end

  class DashPaymentAddress < Address
  end

  # Base class for P2SH and P2PKH addresses
  class Hash160Address < DashPaymentAddress

    HASH160_LENGTH = 20

    def initialize(string: nil, hash: nil, network: nil, _raw_data: nil)
      if string || _raw_data
        _raw_data ||= Base58.data_from_base58check(string)
        if _raw_data.bytesize != (1 + HASH160_LENGTH)
          raise FormatError, "Raw data should have length #{1 + HASH160_LENGTH}, but it is #{_raw_data.bytesize} instead"
        end
        @base58check_string = string
        @data = _raw_data[1, HASH160_LENGTH]
        @version = _raw_data.bytes.first
        @network = nil
      elsif hash
        if hash.bytesize != HASH160_LENGTH
          raise FormatError, "Data should have length #{HASH160_LENGTH}, but it is #{hash.bytesize} instead"
        end
        @base58check_string = nil
        @data = hash
        @version = nil
        @network = network
      else
        raise ArgumentError, "Either data or string must be provided"
      end
    end

    def hash
      @data
    end

    def data_for_base58check_encoding
      Dash.data_from_bytes([self.version].flatten) + @data
    end
  end



  # Standard pulic key (P2PKH) address (e.g. 19FGfswVqxNubJbh1NW8A4t51T9x9RDVWQ)
  class PublicKeyAddress < Hash160Address

    register_class self

    def self.mainnet_version
      76
    end

    def self.testnet_version
      139
    end

    def p2pkh?
      true
    end

    # Instantiates address with a Dash::Key or a binary public key.
    def initialize(string: nil, hash: nil, network: nil, _raw_data: nil, public_key: nil, key: nil)
      if key
        super(hash: Dash.hash160(key.public_key), network: key.network || network)
      elsif public_key
        super(hash: Dash.hash160(public_key), network: network)
      else
        super(string: string, hash: hash, network: network, _raw_data: _raw_data)
      end
    end

    # Returns Dash::Script with data 'OP_DUP OP_HASH160 <hash> OP_EQUALVERIFY OP_CHECKSIG'
    def script
      raise ArgumentError, "Dash::PublicKeyAddress: invalid data length (must be 20 bytes)" if self.data.bytesize != 20
      Dash::Script.new << OP_DUP << OP_HASH160 << self.data << OP_EQUALVERIFY << OP_CHECKSIG
    end
  end


  # P2SH address (e.g. 3NukJ6fYZJ5Kk8bPjycAnruZkE5Q7UW7i8)
  class ScriptHashAddress < Hash160Address

    register_class self

    def self.mainnet_version
      16
    end

    def self.testnet_version
      19
    end

    def p2sh?
      true
    end

    # Instantiates address with a given redeem script.
    def initialize(string: nil, hash: nil, network: nil, _raw_data: nil, redeem_script: nil)
      if redeem_script
        super(hash: Dash.hash160(redeem_script.data), network: network)
      else
        super(string: string, hash: hash, network: network, _raw_data: _raw_data)
      end
    end

    # Returns Dash::Script with data 'OP_HASH160 <hash> OP_EQUAL'
    def script
      raise ArgumentError, "Dash::ScriptHashAddress: invalid data length (must be 20 bytes)" if self.data.bytesize != 20
      Dash::Script.new << OP_HASH160 << self.data << OP_EQUAL
    end
  end
end
