require File.dirname(__FILE__) + '/helper'

class TestSite < Test::Unit::TestCase
  context "creating sites" do
    setup do
      stub(Hyde).configuration do
        Hyde::DEFAULTS.merge({'source' => source_dir, 'destination' => dest_dir})
      end
      @site = Site.new(Hyde.configuration)
    end

    should "reset data before processing" do
      clear_dest
      @site.process
      before_posts = @site.posts.length
      before_layouts = @site.layouts.length

      @site.process
      assert_equal before_posts, @site.posts.length
      assert_equal before_layouts, @site.layouts.length
    end

    should "read layouts" do
      @site.read_layouts
      assert_equal ["default", "simple"].sort, @site.layouts.keys.sort
    end

    should "deploy payload" do
      clear_dest
      @site.process

      posts = Dir[source_dir("**", "_posts", "*")]
      assert_equal posts.size - 1, @site.posts.size
    end

    should "filter entries" do
      ent1 = %w[foo.markdown bar.markdown baz.markdown #baz.markdown#
              .baz.markdow foo.markdown~]
      ent2 = %w[.htaccess _posts bla.bla]

      assert_equal %w[foo.markdown bar.markdown baz.markdown], @site.filter_entries(ent1)
      assert_equal ent2, @site.filter_entries(ent2)
    end
  end
end
