module Hyde

  class Layout
    include Convertible

    attr_accessor :site
    attr_accessor :data, :content

    # Initialize a new Layout.
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
  end
end
