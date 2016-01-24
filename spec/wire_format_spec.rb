require_relative 'spec_helper'
require 'stringio'
describe Dash::WireFormat do

  def verify_varint(int, hex)

    raw = hex.from_hex

    # 1a. Encode to buffer
    Dash::WireFormat.write_varint(int).must_equal(raw)

    # 1b. Write to data buffer
    data = "deadbeef".from_hex
    Dash::WireFormat.write_varint(int, data: data)
    data.to_hex.must_equal("deadbeef" + hex)

    # 1c. Write data to stream
    data = "cafebabe".from_hex
    io = StringIO.new(data)
    io.read # scan forward
    Dash::WireFormat.write_varint(int, stream: io)
    data.to_hex.must_equal("cafebabe" + hex)

    # 2a. Decode from data
    Dash::WireFormat.read_varint(data: raw).must_equal [int, raw.bytesize]
    Dash::WireFormat.read_varint(data: "cafebabe".from_hex + raw, offset: 4).must_equal [int, 4 + raw.bytesize]

    # 2b. Decode from stream
    io = StringIO.new(raw + "deadbeef".from_hex)
    Dash::WireFormat.read_varint(stream: io).must_equal [int, raw.bytesize]

    io = StringIO.new("deadbeef".from_hex + raw + "cafebabe".from_hex)
    Dash::WireFormat.read_varint(stream: io, offset: 4).must_equal [int, 4 + raw.bytesize]
  end

  it "should encode/decode canonical varints" do

    verify_varint(0,             "00")
    verify_varint(252,           "fc")
    verify_varint(255,           "fdff00")
    verify_varint(12345,         "fd3930")
    verify_varint(65535,         "fdffff")
    verify_varint(65536,         "fe00000100")
    verify_varint(1234567890,    "fed2029649")
    verify_varint(1234567890123, "ffcb04fb711f010000")
    verify_varint(2**64 - 1,     "ffffffffffffffffff")

  end

  it "should decode non-canonical varints" do

    Dash::WireFormat.read_varint(data: "fd0000".from_hex).first.must_equal 0x00
    Dash::WireFormat.read_varint(data: "fd1100".from_hex).first.must_equal 0x11

    Dash::WireFormat.read_varint(data: "fe00000000".from_hex).first.must_equal 0x00
    Dash::WireFormat.read_varint(data: "fe11000000".from_hex).first.must_equal 0x11
    Dash::WireFormat.read_varint(data: "fe11220000".from_hex).first.must_equal 0x2211

    Dash::WireFormat.read_varint(data: "ff0000000000000000".from_hex).first.must_equal 0x00
    Dash::WireFormat.read_varint(data: "ff1100000000000000".from_hex).first.must_equal 0x11
    Dash::WireFormat.read_varint(data: "ff1122000000000000".from_hex).first.must_equal 0x2211
    Dash::WireFormat.read_varint(data: "ff1122334400000000".from_hex).first.must_equal 0x44332211

  end

  it "should handle errors when decoding varints" do

    proc { Dash::WireFormat.read_varint() }.must_raise ArgumentError
    proc { Dash::WireFormat.read_varint(data: "".from_hex, stream: StringIO.new("")) }.must_raise ArgumentError

    Dash::WireFormat.read_varint(data: "".from_hex).must_equal [nil, 0]
    Dash::WireFormat.read_varint(data: "fd".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_varint(data: "fd11".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_varint(data: "fe".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_varint(data: "fe112233".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_varint(data: "ff".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_varint(data: "ff11223344556677".from_hex).must_equal [nil, 1]

  end

  it "should handle errors when encoding varints" do

    proc { Dash::WireFormat.write_varint(-1) }.must_raise ArgumentError
    proc { Dash::WireFormat.write_varint(nil) }.must_raise ArgumentError
    proc { Dash::WireFormat.write_varint(2**64) }.must_raise ArgumentError
    proc { Dash::WireFormat.write_varint(2**64 + 1) }.must_raise ArgumentError

  end

  def verify_varstring(string, hex)
    raw = hex.from_hex

    # 1a. Encode to buffer
    Dash::WireFormat.write_string(string).must_equal(raw)

    # 1b. Write to data buffer
    data = "deadbeef".from_hex
    Dash::WireFormat.write_string(string, data: data)
    data.to_hex.must_equal("deadbeef" + hex)

    # 1c. Write data to stream
    data = "cafebabe".from_hex
    io = StringIO.new(data)
    io.read # scan forward
    Dash::WireFormat.write_string(string, stream: io)
    data.to_hex.must_equal("cafebabe" + hex)

    # 2a. Decode from data
    Dash::WireFormat.read_string(data: raw).must_equal [string.b, raw.bytesize]
    Dash::WireFormat.read_string(data: "cafebabe".from_hex + raw, offset: 4).must_equal [string.b, 4 + raw.bytesize]

    # 2b. Decode from stream
    io = StringIO.new(raw + "deadbeef".from_hex)
    Dash::WireFormat.read_string(stream: io).must_equal [string.b, raw.bytesize]

    io = StringIO.new("deadbeef".from_hex + raw + "cafebabe".from_hex)
    Dash::WireFormat.read_string(stream: io, offset: 4).must_equal [string.b, 4 + raw.bytesize]
  end

  it "should encode/decode canonical varstrings" do
    verify_varstring("", "00")
    verify_varstring("\x01", "0101")
    verify_varstring(" ",   "0120")
    verify_varstring("  ",  "022020")
    verify_varstring("   ", "03202020")
    verify_varstring("\xca\xfe\xba\xbe", "04cafebabe")
    verify_varstring("тест", "08d182d0b5d181d182") # 4-letter russian word for "test" (2 bytes per letter in UTF-8)
    verify_varstring("\x42"*255, "fdff00" + "42"*255)
    verify_varstring("\x42"*(256*256), "fe00000100" + "42"*(256*256))
  end

  it "should handle errors when decoding varstrings" do

    proc { Dash::WireFormat.read_string() }.must_raise ArgumentError
    proc { Dash::WireFormat.read_string(data: "".from_hex, stream: StringIO.new("")) }.must_raise ArgumentError

    Dash::WireFormat.read_string(data: "".from_hex).must_equal [nil, 0]
    Dash::WireFormat.read_string(data: "fd".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(data: "fd11".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(data: "fe".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(data: "fe112233".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(data: "ff".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(data: "ff11223344556677".from_hex).must_equal [nil, 1]

    # Not enough data in the string
    Dash::WireFormat.read_string(data: "030102".from_hex).must_equal [nil, 1]
    Dash::WireFormat.read_string(stream: StringIO.new("030102".from_hex)).must_equal [nil, 3]

    Dash::WireFormat.read_string(data: "fd03000102".from_hex).must_equal [nil, 3]
    Dash::WireFormat.read_string(stream: StringIO.new("fd03000102".from_hex)).must_equal [nil, 5]

  end

  it "should handle errors when encoding varstrings" do
    proc { Dash::WireFormat.write_string(nil) }.must_raise ArgumentError
  end

  def verify_fixint(int_type, int, hex)
    raw = hex.from_hex

    # Check data
    v, len = Dash::WireFormat.send("read_#{int_type}", data: raw)
    v.must_equal int
    len.must_equal raw.size

    # Check data + offset + tail
    v, len = Dash::WireFormat.send("read_#{int_type}", data: "abc" + raw + "def", offset: 3)
    v.must_equal int
    len.must_equal raw.size + 3

    # Check stream
    v, len = Dash::WireFormat.send("read_#{int_type}", stream: StringIO.new(raw))
    v.must_equal int
    len.must_equal raw.size

    # Check stream + offset + tail
    v, len = Dash::WireFormat.send("read_#{int_type}", stream: StringIO.new("abc" + raw + "def"), offset: 3)
    v.must_equal int
    len.must_equal raw.size + 3

    Dash::WireFormat.send("encode_#{int_type}", int).must_equal raw
  end

  it "should encode/decode fix-size ints" do

    verify_fixint(:uint8, 0, "00")
    verify_fixint(:uint8, 0x7f, "7f")
    verify_fixint(:uint8, 0x80, "80")
    verify_fixint(:uint8, 0xff, "ff")

    verify_fixint(:int8, 0, "00")
    verify_fixint(:int8, 127, "7f")
    verify_fixint(:int8, -128, "80")
    verify_fixint(:int8, -1, "ff")

    verify_fixint(:uint16le, 0, "0000")
    verify_fixint(:uint16le, 0x7f, "7f00")
    verify_fixint(:uint16le, 0x80, "8000")
    verify_fixint(:uint16le, 0xbeef, "efbe")
    verify_fixint(:uint16le, 0xffff, "ffff")

    verify_fixint(:int16le, 0, "0000")
    verify_fixint(:int16le, 0x7f, "7f00")
    verify_fixint(:int16le, 0x80, "8000")
    verify_fixint(:int16le, -(1<<15), "0080")
    verify_fixint(:int16le, -1, "ffff")

    verify_fixint(:uint32le, 0, "00000000")
    verify_fixint(:uint32le, 0x7f, "7f000000")
    verify_fixint(:uint32le, 0x80, "80000000")
    verify_fixint(:uint32le, 0xbeef, "efbe0000")
    verify_fixint(:uint32le, 0xdeadbeef, "efbeadde")
    verify_fixint(:uint32le, 0xffffffff, "ffffffff")

    verify_fixint(:int32le, 0, "00000000")
    verify_fixint(:int32le, 0x7f, "7f000000")
    verify_fixint(:int32le, 0x80, "80000000")
    verify_fixint(:int32le, 0xbeef, "efbe0000")
    verify_fixint(:int32le, 0x7eadbeef, "efbead7e")
    verify_fixint(:int32le, 0x7fffffff, "ffffff7f")
    verify_fixint(:int32le, -1, "ffffffff")

    verify_fixint(:int32be, 0, "00000000")
    verify_fixint(:int32be, 0x7f, "0000007f")
    verify_fixint(:int32be, 0x80, "00000080")
    verify_fixint(:int32be, 0xbeef, "0000beef")
    verify_fixint(:int32be, 0x7eadbeef, "7eadbeef")
    verify_fixint(:int32be, 0x7fffffff, "7fffffff")
    verify_fixint(:int32be, -1, "ffffffff")

    verify_fixint(:uint64le, 0, "0000000000000000")
    verify_fixint(:uint64le, 0x7f, "7f00000000000000")
    verify_fixint(:uint64le, 0x80, "8000000000000000")
    verify_fixint(:uint64le, 0xbeef, "efbe000000000000")
    verify_fixint(:uint64le, 0xdeadbeef, "efbeadde00000000")
    verify_fixint(:uint64le, 0xdeadbeefcafebabe, "bebafecaefbeadde")
    verify_fixint(:uint64le, 0xffffffffffffffff, "ffffffffffffffff")

    verify_fixint(:int64le, 0, "0000000000000000")
    verify_fixint(:int64le, 0x7f, "7f00000000000000")
    verify_fixint(:int64le, 0x80, "8000000000000000")
    verify_fixint(:int64le, 0xbeef, "efbe000000000000")
    verify_fixint(:int64le, 0xdeadbeef, "efbeadde00000000")
    verify_fixint(:int64le, -(1<<63), "0000000000000080")
    verify_fixint(:int64le, -1, "ffffffffffffffff")

  end

  it "should encode/decode varint-prefixed arrays" do

    txs = [
      Dash::Transaction.new,
      Dash::Transaction.new(inputs:[Dash::TransactionInput.new]),
      Dash::Transaction.new(outputs:[Dash::TransactionOutput.new])
    ]
    data = Dash::WireFormat.encode_array(txs) {|t|t.data}
    data.bytes[0].must_equal txs.size
    data.must_equal txs.inject("\x03".b){|d,t| d+t.data}

    stream = StringIO.new(data)
    txs2 = Dash::WireFormat.read_array(stream: stream){ Dash::Transaction.new(stream: stream) }
    txs2[0].data.must_equal txs[0].data
    txs2[1].data.must_equal txs[1].data
    txs2[2].data.must_equal txs[2].data
  end

end
