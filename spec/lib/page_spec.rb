require_relative "spec_helper"

describe Hyde::Page do

  before do
    layout = ConvertibleHolder.new
    layout.data = {}
    layout.content = "<laybefore>{{ content }}<layafter>"
    @layouts = {"lay" => layout}

    @page = Hyde::Page.new(data_folder(), 
                           "page", 
                           "has-data.html")
    @page.render(@layouts, @page.data)
  end


  it "should render a page" do
    @page.output.should == "<laybefore>Hello Bob!<layafter>"
  end

  it "should write a page" do
    @page.write("/tmp/")
    File.exists?("/tmp/page/has-data.html").should be_true
  end

end
