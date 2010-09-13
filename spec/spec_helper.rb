require 'yaml'

require 'hyde'

# require 'spec'
# require 'spec/interop/test'


# run test with:
# spec page_spec.rb --format specdoc


class ConvertibleHolder
  include Hyde::Convertible

  attr_accessor :content
  attr_accessor :data
  attr_accessor :site
  attr_accessor :output
end

