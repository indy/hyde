require 'pp'
module Hyde

  class Site
    attr_accessor :config, :layouts, :posts, :snippets
    attr_accessor :source, :dest, :zones

    # Initialize the site
    #   +config+ is a Hash containing site configurations details
    #
    # Returns <Site>
    def initialize(config)
      self.config          = config.clone

      self.source          = config['source']
      self.dest            = config['destination']

      self.reset
    end

    def reset
      self.layouts = {}
      self.snippets = {}
      self.zones = {}
    end

    # Do the actual work of processing the site and generating the
    # real deal.
    #
    # Returns nothing
    def process
      self.reset
      self.read_layouts
      self.read_snippets

      self.zones = self.read_zones

      self.transform_pages
    end

    def debug_hash(h)
      p h
      h.each do |k, v|
        p k, v
        debug_hash(v) if v.is_a? Hash
      end
    end

    def folder_info(name)
      base = File.join(self.source, name)
      entries = []
      Dir.chdir(base) { entries = filter_entries(Dir['*.*']) }
      [base, entries]
    end

    # Read all the files in <source>/_layouts into memory for later use.
    #
    # Returns nothing
    def read_layouts
      base, entries = folder_info("_layouts")

      entries.each do |f|
        name = f.split(".")[0..-2].join(".")
        self.layouts[name] = Layout.new(self, base, f)
      end
    rescue Errno::ENOENT => e
      # ignore missing layout dir
    end


    def read_snippets
      base, entries = folder_info("_snippets")

      entries.each do |f|
        name = f.split(".")[0..-2].join(".")
        sn = Snippet.new(self, base, f)
        self.snippets[name] = sn.render(self.layouts, site_payload)
      end
    rescue Errno::ENOENT => e
      # ignore missing layout dir
    end

    def create_posts(dir)
      posts_dir = File.join(dir, '_posts')

      base = File.join(self.source, posts_dir)
      entries = []
      Dir.chdir(base) { entries = filter_entries(Dir['**/*']) }

      # first pass processes, but does not yet render post content

      my_posts = []

      entries.each do |f|
        if Post.valid?(f)
          post = Post.new(self.source, posts_dir, f)

          if not post.draft
            my_posts << post
          end
        end
      end

      my_posts.sort!
    rescue Errno::ENOENT => e
      # ignore missing layout dir
    end

    def read_zones(dir='', structure={})
      base = File.join(self.source, dir)
      entries = filter_entries(Dir.entries(base))
      directories = entries.select { |e| File.directory?(File.join(base, e)) }

      zonal_filename = File.join(base, '_zonal.yaml')
      if File.exist?(zonal_filename)
        structure["zonal"] = YAML.load(IO.read(zonal_filename))
      else
        structure["zonal"] = {}
      end

      if directories.include?('_posts')
        directories.delete('_posts')
        structure["posts"] = create_posts(dir)
      end

      directories.each do |f|
        next if self.dest.sub(/\/$/, '') == File.join(base, f)
        structure[f] = {}
        read_zones(File.join(dir, f), structure[f])
      end

      structure
    end

    def zone_section(dir)
      # get an array of Posts from the correct sub-hash of self.zones
      path = dir.split("/")[1..-1]
      if path
        path.inject(self.zones) { |s, e| s[e] }
      else
        self.zones     # when there are only toplevel posts
      end
    end

    # use the Post structures in zone to render
    def render_posts(dir)
      # render each post now that full site payload is available

      section = zone_section(dir)

      zone_posts = section["posts"]

      payload = site_payload.deep_merge({"zonal" => section["zonal"]})

      zone_posts.each do |post|
        post.render(self.layouts, payload)
        post.write(self.dest)
      end
    rescue Errno::ENOENT => e
      # ignore missing layout dir
    end

    # Copy all regular files from <source> to <dest>/ ignoring
    # any files/directories that are hidden or backup files (start
    # with "." or "#" or end with "~") or contain site content (start with "_")
    # unless they are "_posts" directories or web server files such as
    # '.htaccess'
    #   The +dir+ String is a relative path used to call this method
    #            recursively as it descends through directories
    #
    # Returns nothing
    def transform_pages(dir = '')
      base = File.join(self.source, dir)
      entries = filter_entries(Dir.entries(base))
      directories = entries.select { |e| File.directory?(File.join(base, e)) }
      files = entries.reject { |e| File.directory?(File.join(base, e)) }

      # we need to make sure to process _posts *first* otherwise they
      # might not be available yet to other templates as {{ site.posts }}
      if directories.include?('_posts')
        directories.delete('_posts')
        render_posts(dir)
      end
      [directories, files].each do |entries|
        entries.each do |f|
          if File.directory?(File.join(base, f))
            next if self.dest.sub(/\/$/, '') == File.join(base, f)
            transform_pages(File.join(dir, f))
          else
            first3 = File.open(File.join(self.source, dir, f)) { |fd| fd.read(3) }

            if first3 == "---"
              # file appears to have a YAML header so process it as a page
              page = Page.new(self.source, dir, f)

              section = zone_section(dir)
              payload = site_payload.deep_merge({"zonal" => section["zonal"]})

              page.render(self.layouts, payload)
              page.write(self.dest)
            else
              # otherwise copy the file without transforming it
              FileUtils.mkdir_p(File.join(self.dest, dir))
              FileUtils.cp(File.join(self.source, dir, f), File.join(self.dest, dir, f))
            end
          end
        end
      end
    end

    def site_payload
      {"site" => {
          "name" => "indy.io"
        },
        "snippet" => self.snippets,
        "zone" => self.zones
      }
    end

    # Filter out any files/directories that are hidden or backup files (start
    # with "." or "#" or end with "~") or contain site content (start with "_")
    # unless they are "_posts" directories or web server files such as
    # '.htaccess'
    def filter_entries(entries)
      entries = entries.reject do |e|
        unless ['_posts', '.htaccess'].include?(e)
          # Reject backup/hidden
          ['.', '_', '#'].include?(e[0..0]) or e[-1..-1] == '~'
        end
      end
    end

  end
end
