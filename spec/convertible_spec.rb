require 'spec_helper'

class ConvertibleHolder
  include Hyde::Convertible

  attr_accessor :content
  attr_accessor :data
  attr_accessor :site
  attr_accessor :output
end

describe ConvertibleHolder do
  it "should the read YAML header" do
    ch = ConvertibleHolder.new

    base = File.join(File.dirname(__FILE__), "source", "convertible")

    ch.read_yaml(base, "content-only.html")
    ch.content.should == "Hello world!\n"
    ch.data.should == nil

    ch.read_yaml(base, "has-data.html")
    ch.content.should == "Hello world!\n"
    ch.data["title"].should == "A test page"
  end


  it "should render the content" do
    ch = ConvertibleHolder.new

    ch.data = {}
    ch.content = "<before>{{ title }}<after>"

    ch.do_layout({'title' => "indy.io"}, {})

    ch.output.should == "<before>indy.io<after>"
  end

  it "should calculate the layout" do

    layout = ConvertibleHolder.new
    layout.data = {}
    layout.content = "<laybefore>{{ content }}<layafter>"

    layouts = {"lay" => layout}

    ch = ConvertibleHolder.new
    ch.data = {"layout" => "lay"}
    ch.content = "<before>{{ title }}<after>"

    ch.do_layout({'title' => "indy.io"}, layouts)

    ch.output.should == "<laybefore><before>indy.io<after><layafter>"
  end
end
