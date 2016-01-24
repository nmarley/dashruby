require_relative 'spec_helper'

describe Dash::Diagnostics do

  it "should record messages" do

    Dash::Diagnostics.current.wont_be_nil

    # Due to other tests this may not be nil, so we should not check for it.
    # We also should not clear the state in order to test our recording code against whatever state was there before.
    # Dash::Diagnostics.current.last_message.must_equal nil

    Dash::Diagnostics.current.add_message("msg1")
    Dash::Diagnostics.current.last_message.must_equal "msg1"
    Dash::Diagnostics.current.add_message("msg2")
    Dash::Diagnostics.current.last_message.must_equal "msg2"

    Dash::Diagnostics.current.record do

      Dash::Diagnostics.current.record do
        Dash::Diagnostics.current.add_message("a")
        Dash::Diagnostics.current.add_message("b")
        Dash::Diagnostics.current.last_message.must_equal "b"
      end.map(&:to_s).must_equal ["a", "b"]

      Dash::Diagnostics.current.last_message.must_equal "b"

      Dash::Diagnostics.current.add_message("c")

      Dash::Diagnostics.current.record do
        Dash::Diagnostics.current.add_message("d")
        Dash::Diagnostics.current.add_message("e")
      end.map(&:to_s).must_equal ["d", "e"]

    end.map(&:to_s).must_equal ["a", "b", "c", "d", "e"]

    Dash::Diagnostics.current.last_message.must_equal "e"

  end

end
