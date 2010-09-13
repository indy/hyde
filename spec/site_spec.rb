require 'spec_helper'

describe Hyde::Site do

  before do
    config = {'source' => File.join(File.dirname(__FILE__), "source", "site"),
              'destination' => '/tmp/'}

    @site = Hyde::Site.new(config)
  end

  it "should read layouts" do
    @site.read_layouts
    @site.layouts.length.should == 5
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
end
