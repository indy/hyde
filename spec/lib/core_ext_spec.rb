require_relative 'spec_helper'

describe Hash do
  it "should deep merge a hash" do
    h1 = {:a => 1, :b => {:c => 2}}
    h2 = {:z => 3, :b => {:d => 4}}

    h1.deep_merge(h2).should == {:a => 1, :z => 3, :b => {:c => 2, :d => 4}}
  end
end
