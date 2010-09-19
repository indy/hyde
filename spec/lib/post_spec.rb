require_relative "spec_helper"

describe Hyde::Post do

  before do
    layout = ConvertibleHolder.new
    layout.data = {}
    layout.content = "<laybefore>{{ content }}<layafter>"
    @layouts = {"lay" => layout}

    @postname = "2010-09-13-sample-post.html"
    @post = Hyde::Post.new(data_folder(), 
                           File.join('post', '_posts'), 
                           @postname)
    @post.render(@layouts, {})
  end

  it "should be named with a valid format" do
    Hyde::Post.valid?(@postname).should be_true
  end

  it "should have a valid post id" do
    @post.id.should == "post/sample-post"
  end



end
