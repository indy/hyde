module Hyde

  class Page
    include Convertible

    attr_accessor :site
    attr_accessor :data, :content, :output

    # Initialize a new Page.
    #   +site+ is the Site
    #   +base+ is the String path to the <source>
    #   +dir+ is the String path between <source> and the file
    #   +name+ is the String filename of the file
    #
    # Returns <Page>
    def initialize(site, base, dir, name)
      @site = site
      @base = base
      @dir = dir
      @name = name

      self.read_yaml(File.join(base, dir), name)
      self.data ||= {}
      self.data["folder"] = @dir
    end

    # Add any necessary layouts to this post
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def render(layouts, site_payload)
      payload = {"page" => self.data}.deep_merge(site_payload)
      do_layout(payload, layouts)
    end

    # Write the generated page file to the destination directory.
    #   +dest+ is the String path to the destination dir
    #
    # Returns nothing
    def write(dest)
      FileUtils.mkdir_p(File.join(dest, @dir))

      path = File.join(dest, @dir, @name)
      File.open(path, 'w') do |f|
        f.write(self.output)
      end
    end
  end

end
