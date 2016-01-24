require_relative 'spec_helper'

describe Dash::CurrencyFormatter do

  it "should support normal Dash formatting" do
    fm = Dash::CurrencyFormatter.dash_formatter

    fm.string_from_number(1*Dash::COIN).must_equal("1.0")
    fm.string_from_number(42*Dash::COIN).must_equal("42.0")
    fm.string_from_number(42000*Dash::COIN).must_equal("42000.0")
    fm.string_from_number(42000*Dash::COIN + 123).must_equal("42000.00000123")
    fm.string_from_number(42000*Dash::COIN + 123000).must_equal("42000.00123")
    fm.string_from_number(42000*Dash::COIN + 123456).must_equal("42000.00123456")
    fm.string_from_number(42000*Dash::COIN + Dash::COIN/2).must_equal("42000.5")

    fm.number_from_string("1").must_equal 1*Dash::COIN
    fm.number_from_string("1.").must_equal 1*Dash::COIN
    fm.number_from_string("1.0").must_equal 1*Dash::COIN
    fm.number_from_string("42").must_equal 42*Dash::COIN
    fm.number_from_string("42.123").must_equal 42*Dash::COIN + 12300000
    fm.number_from_string("42.12345678").must_equal 42*Dash::COIN + 12345678
    fm.number_from_string("42.10000000").must_equal 42*Dash::COIN + 10000000
    fm.number_from_string("42.10000").must_equal    42*Dash::COIN + 10000000
  end

  it "should support long Dash formatting" do
    fm = Dash::CurrencyFormatter.dash_long_formatter

    fm.string_from_number(1*Dash::COIN).must_equal("1.00000000")
    fm.string_from_number(42*Dash::COIN).must_equal("42.00000000")
    fm.string_from_number(42000*Dash::COIN).must_equal("42000.00000000")
    fm.string_from_number(42000*Dash::COIN + 123).must_equal("42000.00000123")
    fm.string_from_number(42000*Dash::COIN + 123000).must_equal("42000.00123000")
    fm.string_from_number(42000*Dash::COIN + 123456).must_equal("42000.00123456")
    fm.string_from_number(42000*Dash::COIN + Dash::COIN/2).must_equal("42000.50000000")

    fm.number_from_string("1").must_equal 1*Dash::COIN
    fm.number_from_string("1.").must_equal 1*Dash::COIN
    fm.number_from_string("1.0").must_equal 1*Dash::COIN
    fm.number_from_string("42").must_equal 42*Dash::COIN
    fm.number_from_string("42.123").must_equal 42*Dash::COIN + 12300000
    fm.number_from_string("42.12345678").must_equal 42*Dash::COIN + 12345678
    fm.number_from_string("42.10000000").must_equal 42*Dash::COIN + 10000000
    fm.number_from_string("42.10000").must_equal    42*Dash::COIN + 10000000
  end
end
