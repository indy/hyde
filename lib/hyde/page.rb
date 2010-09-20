module Hyde

  class Page
    include Comparable
    include Convertible

    MATCHER = /^(\d+-\d+-\d+)-(.*)(\.[^.]+)$/
    LOOSE_MATCHER = /^(.*)(\.[^.]+)$/

    # Returns <Bool>
    def self.valid?(name)
      name =~ MATCHER || name =~ LOOSE_MATCHER
    end

    attr_accessor :data, :content, :output
    attr_accessor :slug, :ext, :draft, :date

    # Initialize a new Page.
    #   +site+ is the Site
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #   +name+ is the String filename of the file
    #
    # Returns <Page>
    def initialize(base, dir, name)
#      puts "PAGE: base=#{base}, dir=#{dir}, name=#{name}"

      # is this a post?
      if dir.split('/')[-1] == '_posts' 
        @dir = dir.split('/')[0..-2].join('/')
      else
        @dir = dir
      end

      if name =~ MATCHER
        @sort_alpha = false
      elsif name =~ LOOSE_MATCHER
        @sort_alpha = true
      end

      @name = name

      if @sort_alpha
        all, slug, ext = *name.match(LOOSE_MATCHER)
      else
        all, date, slug, ext = *name.match(MATCHER)
        self.date = Time.parse(date)
      end
      self.slug = slug

      self.read_yaml(File.join(base, dir), name)
      self.data ||= {}

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

    # The generated relative url of this post
    #
    # Returns <String>
    def url
      @dir + '/' + self.slug + '.html'
    end

    # Add any necessary layouts to this post
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def render(layouts, site_payload)
      payload = {
        "site" => {},
        "page" => self.to_liquid
      }

      payload = payload.deep_merge(site_payload)

      do_layout(payload, layouts)
    end


    # Write the generated page file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      FileUtils.mkdir_p(File.join(dest, @dir))

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
        "folder" => @dir,
        "date" => self.date,
        "content" => self.content }.deep_merge(self.data)
    end

    def inspect
      "<Post: #{self.url}>"
    end


  end

end
