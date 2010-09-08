module Hyde

  class Post
    include Comparable
    include Convertible

    MATCHER = /^(.+\/)*(\d+-\d+-\d+)-(.*)(\.[^.]+)$/

    # Post name validator. Post filenames must be like:
    #   2008-11-05-my-awesome-post.html
    #
    # Returns <Bool>
    def self.valid?(name)
      name =~ MATCHER
    end

    attr_accessor :site
    attr_accessor :date, :slug, :ext, :topics, :draft
    attr_accessor :data, :content, :output

    # Initialize this Post instance.
    #   +site+ is the Site
    #   +base+ is the String path to the dir containing the post file
    #   +name+ is the String filename of the post file
    #
    # Returns <Post>
    def initialize(site, source, dir, name)
      @site = site
      @base = File.join(source, dir, '_posts')
      @name = name

      parts = name.split('/')
      self.topics = parts.size > 1 ? parts[0..-2] : []

      @base_dir = dir

      self.process(name)
      self.read_yaml(@base, name)

      if self.data.has_key?('draft') && self.data['draft'] == true
        self.draft = true
      else
        self.draft = false
      end
    end

    # Spaceship is based on Post#date
    #
    # Returns -1, 0, 1
    def <=>(other)
      self.date <=> other.date
    end

    # Extract information from the post filename
    #   +name+ is the String filename of the post file
    #
    # Returns nothing
    def process(name)
      m, cats, date, slug, ext = *name.match(MATCHER)
      self.date = Time.parse(date)
      self.slug = slug
      self.ext = ext
    end

    # The generated directory into which the post will be placed
    # upon generation.
    #
    # Returns <String>
    def dir
      @base_dir + '/'
    end

    # The generated relative url of this post
    #
    # Returns <String>
    def url
      self.id + '.html'
    end

    def folder
      @base_dir
    end

    # The UID for this post (useful in feeds)
    # e.g. /2008/11/05/my-awesome-post
    #
    # Returns <String>
    def id
      self.dir + self.slug
    end

    # Calculate related posts.
    #
    # Returns [<Post>]
    def related_posts(posts)
      return [] unless posts.size > 1
      (posts - [self])[0..9]
    end

    # Add any necessary layouts to this post
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def render(layouts, site_payload)
      # construct payload
      payload =
      {
        "site" => { "related_posts" => related_posts(site_payload["site"]["posts"]) },
        "page" => self.to_liquid
      }
      payload = payload.deep_merge(site_payload)

      do_layout(payload, layouts)
    end

    # Write the generated post file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      FileUtils.mkdir_p(File.join(dest, dir))

      path = File.join(dest, self.url)

      File.open(path, 'w') do |f|
        f.write(self.output)
      end
    end

    # Convert this post into a Hash for use in Liquid templates.
    #
    # Returns <Hash>
    def to_liquid
      { "title" => self.data["title"] || self.slug.split('-').select {|w| w.capitalize! || w }.join(' '),
        "url" => self.url,
        "folder" => self.folder,
        "date" => self.date,
        "id" => self.id,
        "topics" => self.topics,
        "content" => self.content }.deep_merge(self.data)
    end

    def inspect
      "<Post: #{self.id}>"
    end
  end

end
