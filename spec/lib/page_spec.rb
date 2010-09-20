require_relative "spec_helper"

describe Hyde::Page do

  before do
    layout = ConvertibleHolder.new
    layout.data = {}
    layout.content = "<laybefore>{{ content }}<layafter>"
    @layouts = {"lay" => layout}

  end


  it "should render a page" do
    @page = Hyde::Page.new(data_folder(), 
                           "page", 
                           "has-data.html")
    @page.render(@layouts, @page.data)
    @page.output.should == "<laybefore>Hello Bob!<layafter>"
  end

  it "should write a page" do
    @page = Hyde::Page.new(data_folder(), 
                           "page", 
                           "has-data.html")
    @page.render(@layouts, @page.data)
    @page.write("/tmp/")
    File.exists?("/tmp/page/has-data.html").should be_true
  end



  it "should be named with a valid format" do
    postname = "2010-09-13-sample-post.html"
    Hyde::Page.valid?(postname).should be_true
  end

  it "should have a valid post id" do
    postname = "2010-09-13-sample-post.html"
    @post = Hyde::Page.new(data_folder(), 
                           File.join('page', '_posts'), 
                           postname)
    @post.render(@layouts, @post.data)
    @post.url.should == "page/sample-post.html"
  end

end
