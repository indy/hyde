module Hyde

  class Post
    include Comparable
    include Convertible

    MATCHER = /^(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
    LOOSE_MATCHER = /^(.*)(\.[^.]+)$/

    # Returns <Bool>
    def self.valid?(name)
      name =~ MATCHER || name =~ LOOSE_MATCHER
    end

    attr_accessor :date, :slug, :draft
    attr_accessor :data, :content, :output

    # Initialize this Post instance.
    #   +site+ is the Site
    #   +base+ is the String path to the dir containing the post file
    #   +name+ is the String filename of the post file
    #
    # Returns <Post>
    def initialize(base, dir, name)
#      puts "POST base=#{base}, dir=#{dir}, name=#{name}"

      # is this a post?
      if dir.split('/')[-1] == '_posts' 
        @base_dir = dir.split('/')[0..-2].join('/')
      else
        @base_dir = dir
      end


      if name =~ MATCHER
        @sort_alpha = false
      elsif name =~ LOOSE_MATCHER
        @sort_alpha = true
      end

      @base = File.join(base, dir)
      @name = name

      if @sort_alpha
        all, slug, ext = *name.match(LOOSE_MATCHER)
      else
        all, date, slug, ext = *name.match(MATCHER)
        self.date = Time.parse(date)
      end
      self.slug = slug

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
      if @sort_alpha
        self.slug <=> other.slug
      else
        other.date <=> self.date
      end
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
    # e.g. my-awesome-post
    #
    # Returns <String>
    def id
      self.dir + self.slug
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
        "site" => {},
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
        "content" => self.content }.deep_merge(self.data)
    end

    def inspect
      "<Post: #{self.id}>"
    end
  end

end
