require_relative "spec_helper"

describe Hyde::Post do

  before do
    layout = ConvertibleHolder.new
    layout.data = {}
    layout.content = "<laybefore>{{ content }}<layafter>"
    @layouts = {"lay" => layout}

    @postname = "2010-09-13-sample-post.html"
    @post = Hyde::Post.new("testsite", 
                           data_folder(), 
                           "post", 
                           @postname)
    @post.render(@layouts, {})
  end

  it "should be named with a valid format" do
    Hyde::Post.valid?(@postname).should be_true
  end

  it "should have a valid post id" do
    @post.id.should == "post/sample-post"
  end

  it "should compare against the postdate" do
    pending "reverse the existing comparison operation"
  end
  it "should render a post" do
    pending "check post creation"
  end
  it "should write a post" do
    pending "check post writing"
  end
  it "should convert the post to a hash" do
    pending "for use in Liquid templates"
  end


end
