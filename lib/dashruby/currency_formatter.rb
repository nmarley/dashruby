require 'bigdecimal'

module Dash
  # Modeled after NSNumberFormatter in Cocoa, this class allows to convert
  # Dash amounts to their string representations and vice versa.
  class CurrencyFormatter

    STYLE_DASH      = :dash       # 1.0 is 1 dash (100_000_000 duffs)
    STYLE_DASH_LONG = :dash_long  # 1.00000000 is 1 dash (100_000_000 duffs)
    STYLE_MDASH     = :mdash      # 1.0 is 0.001 dash (100_000 duffs)
    STYLE_BIT       = :bit       # 1.0 is 0.000001 dash (100 duffs)
    STYLE_DUFFS     = :duffs  # 1.0 is 0.00000001 dash (1 duff)

    attr_accessor :style
    attr_accessor :show_suffix

    # Returns a singleton formatter for Dash values (1.0 is one Dash) without suffix.
    def self.dash_formatter
      @dash_formatter ||= self.new(style: STYLE_DASH)
    end

    # Returns a singleton formatter for Dash values where there are always 8 places
    # after decimal point (e.g. "42.00000000").
    def self.dash_long_formatter
      @dash_long_formatter ||= self.new(style: STYLE_DASH_LONG)
    end

    def initialize(style: :dash, show_suffix: false)
      @style = style
      @show_suffix = show_suffix
    end

    # Returns formatted string for an amount in duffs.
    def string_from_number(number)
      if @style == :dash
        number = number.to_i
        return "#{number / Dash::COIN}.#{'%08d' % [number % Dash::COIN]}".gsub(/0+$/,"").gsub(/\.$/,".0")
      elsif @style == :dash_long
        number = number.to_i
        return "#{number / Dash::COIN}.#{'%08d' % [number % Dash::COIN]}"
      else
        # TODO: parse other styles
        raise "Not implemented"
      end
    end

    # Returns amount of duffs parsed from a formatted string according to style attribute.
    def number_from_string(string)
      bd = BigDecimal.new(string)
      if @style == :dash || @style == :dash_long
        return (bd * Dash::COIN).to_i
      else
        # TODO: support other styles
        raise "Not Implemented"
      end
    end

    # Creates a copy if you want to customize another formatter (e.g. a global singleton like dash_formatter)
    def dup
      self.class.new(style: @style, show_suffix: @show_suffix)
    end

  end # DashFormatter
end # Dash
