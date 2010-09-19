require_relative 'spec_helper'

require 'fileutils'

describe Hyde::Site do

  before(:all) do
    FileUtils.mkdir("/tmp/hyde")

    @destination  = '/tmp/hyde'
    config = {'source' => File.join(data_folder(), "site"),
              'destination' => @destination}

    @site = Hyde::Site.new(config)

    @site.process
  end

  after(:all) do
    FileUtils.rm_rf("/tmp/hyde")
  end

  it "should read layouts" do
    @site.read_layouts
    @site.layouts.length.should == 6
  end

  it "should create posts" do
    posts = @site.create_posts("journal")
    posts.length.should == 7
  end

  it "should read zones" do
    zones = @site.read_zones
    zones["projects"]["tecs"]["zonal"]["bookcover"].should == "some-cover.jpg"
  end

  it "should apply zonal information to pages" do
    page = File.join(@destination, 'projects', 'sample', 'index.html')
    content = IO.read(page)
    content.should == "<foo><p>Index</p><bar>\n<baz>sample<baq>"
  end

  it "should apply zonal information to posts" do
    page = File.join(@destination, 'projects', 'sample', 'p01.html')
    content = IO.read(page)
    content.should == "<foo><p>post1</p><bar>\n<baz>sample<baq>"
  end

  it "should allow posts to be sorted alphanumerically" do
    page = File.join(@destination, 'projects', 'sortalpha', 'index.html')
    content = IO.read(page)
    content.should == "<foo><li>xxx</li><li>yyy</li><li>zzz</li><bar>\n<baz>sort-alpha<baq>"
  end

  it "should make dates optional" do
    
  end

end
