module Hyde

  class Snippet
    include Convertible

    attr_accessor :site
    attr_accessor :data, :content
    attr_accessor :output

    # Initialize a new snippet
    #   +site+ is the Site
    #   +base+ is the String path to the <source>
    #   +name+ is the String filename of the post file
    #
    # Returns <Page>
    def initialize(site, base, name)
      @site = site
      @base = base
      @name = name

      self.data = {}

      self.read_yaml(base, name)
    end

    # Add any necessary layouts to this post
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns output
    def render(layouts, site_payload)
      payload = {"page" => self.data}.deep_merge(site_payload)
      do_layout(payload, layouts)
      self.output
    end


  end

end
