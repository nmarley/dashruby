# DashRuby

DashRuby is a clone of DashRuby, used for creating [Dash](https://www.dash.org/) applications.

**Warning: This library is currently in alpha stage. Use at your own risk.**

## Documentation and Examples

Please see [DashRuby Reference](documentation/index.md) for API documentation and examples.

## Basic Features

* Encoding/decoding of addresses, WIF private keys (`Dash::Address`).
* APIs to construct and inspect blocks, transactions and scripts.
* Native BIP32 and BIP44 ("HW Wallets") support (see `Dash::Keychain`).
* Explicit APIs to handle compressed and uncompressed public keys.
* Explicit APIs to handle mainnet/testnet (see `Dash::Network`)
* Consistent API for data encoding used throughout the library itself (see `Dash::Data` and `Dash::WireFormat`).
* Flexible transaction builder that can work with arbitrary data sources that provide unspent outputs.
* Handy extensions on built-in classes (e.g. `String#to_hex`) are optional (see `extensions.rb`).
* Optional attributes on Transaction, TransactionOutput and TransactionInput to hold additional data
  provided by 3rd party APIs.

## Advanced Features

* ECDSA signatures are deterministic and normalized according to [RFC6979](https://tools.ietf.org/html/rfc6979)
  and [BIP62](https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki).
* Automatic normalization of existing ECDSA signatures (see `Dash::Key#normalized_signature`).
* Rich script analysis and compositing support (see `Dash::Script`).
* Full script interpreter with [P2SH](https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki) and [CLTV](https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki) features.
* Powerful diagnostics API covering the entire library (see `Dash::Diagnostics`).
* Canonicality checks for transactions, public keys and script elements.
* Fee computation and signature script simulation for building transactions without signing them.

## Philosophy

* We use clear, expressive names for all methods and classes.
* Self-contained implementation. Only external dependency is `ffi` gem that helps linking directly with OpenSSL and libsecp256k1.
* For efficiency and consistency we use binary strings throughout the library (not the hex strings as in other libraries).
* We do not pollute standard classes with our methods. To use utility extensions like `String#to_hex` you should explicitly `require 'dashruby/extensions'`.
* We use OpenSSL `BIGNUM` implementation where compatibility is critical (instead of the built-in Ruby Bignum).
* We enforces canonical and determinstic ECDSA signatures for maximum compatibility and security using native OpenSSL functions.
* We treat endianness explicitly. Even though most systems are little-endian, it never hurts to show where indianness is important.

The goal is to provide a complete Dash toolkit in Ruby.

## How to run tests

```
$ bundle install
$ brew install ./vendor/homebrew/secp256k1.rb
$ rake
```

## How to publish a gem

1. Edit version.rb to bump the version.
2. Update `RELEASE_NOTES.md`.
3. Commit changes and tag it with new version.
4. Generate and publish the gem:

```
$ git tag VERSION
$ git push origin --tags
$ gem build dashruby.gemspec
$ gem push dashruby-VERSION.gem
```

## Authors

* [Oleg Andreev](http://oleganza.com/)
* [Ryan Smith](http://r.32k.io)
* [Nathan Marley](http://marley.io/)
