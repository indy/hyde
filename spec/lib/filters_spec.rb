require_relative 'spec_helper'

class FiltersHolder
  include Hyde::Filters

  def into_sentence(arr)
    array_to_sentence_string(arr)
  end
end

describe FiltersHolder do
  it "should convert an array to english" do
    fc = FiltersHolder.new

    fc.into_sentence(%w[a]).should == "a"
    fc.into_sentence(%w[a b]).should == "a and b"
    fc.into_sentence(%w[a b c]).should == "a, b, and c"
  end
end
