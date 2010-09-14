# Convertible provides methods for converting a pagelike item
# from a certain type of markup into actual content
#
# Requires
#   self.site -> Hyde::Site
module Hyde
  module Convertible
    # Return the contents as a string
    def to_s
      self.content || ''
    end

    # Read the YAML frontmatter
    #   +base+ is the String path to the dir containing the file
    #   +name+ is the String filename of the file
    #
    # Returns nothing
    def read_yaml(base, name)
      self.content = File.read(File.join(base, name))

      if self.content =~ /^(---\s*\n.*?)\n---\s*\n/m
        self.content = self.content[($1.size + 5)..-1]

        self.data = YAML.load($1)
      end

      self.content.strip!
    end

    # Add any necessary layouts to this convertible document
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def do_layout(payload, layouts)
      info = { :filters => [Hyde::Filters], :registers => { :site => self.site } }
#      payload["content_type"] = "unknown"
      self.content = Liquid::Template.parse(self.content).render(payload, info)

      # output keeps track of what will finally be written
      self.output = self.content

      # recursively render layouts
      layout = layouts[self.data["layout"]]
      while layout
        payload = payload.deep_merge({"content" => self.output, "page" => layout.data})
        self.output = Liquid::Template.parse(layout.content).render(payload, info)

        layout = layouts[layout.data["layout"]]
      end
    end
  end
end
