require_relative 'spec_helper'

describe ConvertibleHolder do
  it "should the read YAML header" do
    ch = ConvertibleHolder.new

    base = File.join(data_folder, "convertible")

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

  it "should calculate a nested layout" do

    layout2 = ConvertibleHolder.new
    layout2.data = {}
    layout2.content = "<lay2before>{{ content }}<lay2after>"

    layout = ConvertibleHolder.new
    layout.data = {"layout" => "lay2"}
    layout.content = "<laybefore>{{ content }}<layafter>"

    layouts = {"lay" => layout, "lay2" => layout2}

    ch = ConvertibleHolder.new
    ch.data = {"layout" => "lay"}
    ch.content = "<before>{{ title }}<after>"

    ch.do_layout({'title' => "indy.io"}, layouts)

    ch.output.should == "<lay2before><laybefore><before>indy.io<after><layafter><lay2after>"
  end
end
