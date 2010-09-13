require "spec_helper"

describe Hyde::Page do
  it "should return the contents as a string" do
    source = File.join(File.dirname(__FILE__), "source")
    content_only = Hyde::Page.new("testsite", 
                                  source, 
                                  "page", 
                                  "content-only.html")
    content_only.to_s.should == "Hello world!\n"

    has_data = Hyde::Page.new("testsite", 
                              source, 
                              "page", 
                              "has-data.html")
    has_data.to_s.should == "Hello world!\n"
  end

end
