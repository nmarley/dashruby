module Dash
  module StringExtensions

    # Converts binary string as a private key to a WIF Base58 format.
    def to_wif(network: nil, public_key_compressed: nil)
      Dash::WIF.new(private_key: self, network: network, public_key_compressed: public_key_compressed).to_s
    end

    # Decodes string in WIF format into a binary private key (32 bytes)
    def from_wif
      addr = Dash::WIF.new(string: self)
      addr ? addr.private_key : nil
    end

    # Converts binary data into hex string
    def to_hex
      Dash.to_hex(self)
    end

    # Converts hex string into a binary data
    def from_hex
      Dash.from_hex(self)
    end

    # Various hash functions
    def hash256
      Dash.hash256(self)
    end

    def hash160
      Dash.hash160(self)
    end

    def sha1
      Dash.sha1(self)
    end

    def ripemd160
      Dash.ripemd160(self)
    end

    def sha256
      Dash.sha256(self)
    end

    def sha512
      Dash.sha512(self)
    end

  end
end

class ::String
  include Dash::StringExtensions
end