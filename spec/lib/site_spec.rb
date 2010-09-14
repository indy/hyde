require_relative 'spec_helper'

describe Hyde::Site do

  before do
    @destination  = '/tmp/'
    config = {'source' => File.join(data_folder(), "site"),
              'destination' => @destination}

    @site = Hyde::Site.new(config)
  end

  it "should read layouts" do
    @site.read_layouts
    @site.layouts.length.should == 6
  end

  it "should read snippets" do
    @site.read_snippets
    @site.snippets.length.should == 2
  end

  it "should create posts" do
    posts = @site.create_posts "journal"
    posts.length.should == 7
  end

  it "should read zones" do
    zones = @site.read_zones
    zones["projects"]["tecs"]["zonal"]["bookcover"].should == "some-cover.jpg"
  end

  it "should apply zonal information to pages" do
    @site.process
    @site.transform_pages
    
    page = File.join(@destination, 'projects', 'sample', 'index.html')
    content = IO.read(page)
    content.should == "<foo><p>Index</p><bar>\n<baz>sample<baq>"
  end

  it "should apply zonal information to posts" do
    @site.process
    @site.transform_pages
    
    page = File.join(@destination, 'projects', 'sample', 'p01.html')
    content = IO.read(page)
    content.should == "<foo><p>post1</p><bar>\n<baz>sample<baq>"
  end

end
