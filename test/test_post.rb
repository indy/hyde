require File.dirname(__FILE__) + '/helper'

class TestPost < Test::Unit::TestCase
  def setup_post(file)
    Post.new(@site, source_dir, '', file)
  end

  def do_render(post)
    layouts = { "default" => Layout.new(@site, source_dir('_layouts'), "simple.html")}
    post.render(layouts, {"site" => {"posts" => []}})
  end

  context "A Post" do
    setup do
      clear_dest
      stub(Hyde).configuration { Hyde::DEFAULTS }
      @site = Site.new(Hyde.configuration)
    end

    should "ensure valid posts are valid" do
      assert Post.valid?("2008-10-19-foo-bar.textile")
      assert Post.valid?("foo/bar/2008-10-19-foo-bar.textile")

      assert !Post.valid?("lol2008-10-19-foo-bar.textile")
      assert !Post.valid?("blah")
    end

    context "processing posts" do
      setup do
        @post = Post.allocate
        @post.site = @site

        @real_file = "2008-10-18-foo-bar.textile"
        @fake_file = "2008-10-19-foo-bar.textile"
        @source = source_dir('_posts')
      end

      should "keep date, title, and markup type" do
        @post.process(@fake_file)

        assert_equal Time.parse("2008-10-19"), @post.date
        assert_equal "foo-bar", @post.slug
        assert_equal ".textile", @post.ext
      end

      should "read yaml front-matter" do
        @post.read_yaml(@source, @real_file)

        assert_equal({"title" => "Foo Bar", "layout" => "default"}, @post.data)
        assert_equal "\nh1. {{ page.title }}\n\nBest *post* ever", @post.content
      end

      should "transform textile" do
        @post.process(@real_file)
        @post.read_yaml(@source, @real_file)
        @post.transform

        assert_equal "<h1>{{ page.title }}</h1>\n<p>Best <strong>post</strong> ever</p>", @post.content
      end
    end

    context "initializing posts" do
      should "publish when draft yaml is no specified" do
        post = setup_post("2008-02-02-published.textile")
        assert_equal false, post.draft
      end

      should "not published when draft yaml is true" do
        post = setup_post("2008-02-02-not-published.textile")
        assert_equal true, post.draft
      end

      context "rendering" do
        setup do
          clear_dest
        end

        should "render properly" do
          post = setup_post("2008-10-18-foo-bar.textile")
          do_render(post)
          assert_equal "<<< <h1>Foo Bar</h1>\n<p>Best <strong>post</strong> ever</p> >>>", post.output
        end

        should "write properly" do
          post = setup_post("2008-10-18-foo-bar.textile")
          do_render(post)
          post.write(dest_dir)

          assert File.directory?(dest_dir)
          assert File.exists?(File.join(dest_dir, 'foo-bar.html'))
        end

        should "insert data" do
          post = setup_post("2008-11-21-complex.textile")
          do_render(post)

          assert_equal "<<< <p>url: /complex.html<br />\ndate: #{Time.parse("2008-11-21")}<br />\nid: /complex</p> >>>", post.output
        end

      end
    end

    should "generate categories and topics" do
      post = Post.new(@site, File.join(File.dirname(__FILE__), *%w[source]), 'foo', 'bar/2008-12-12-topical-post.textile')
      assert_equal ['bar'], post.topics
    end

  end
end
