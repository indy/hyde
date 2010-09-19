$:.unshift File.dirname(__FILE__)     # For use/testing when no gem is installed

# rubygems
require 'rubygems'

# core
require 'fileutils'
require 'time'
require 'yaml'

# stdlib

# 3rd party
require 'liquid'
require 'redcloth'

# internal requires
require 'hyde/core_ext'
require 'hyde/site'
require 'hyde/convertible'
require 'hyde/layout'
require 'hyde/page'
require 'hyde/filters'

module Hyde
  # Default options. Overriden by values in _config.yaml or command-line opts.
  # (Strings rather symbols used for compatability with YAML)
  DEFAULTS = {
    'source'       => '.',
    'destination'  => File.join('.', '_site'),
    'permalink'    => 'date',
  }

  # Generate a Hyde configuration Hash
  #
  # Returns Hash
  def self.configuration(override)
     # Merge DEFAULTS < override
    Hyde::DEFAULTS.deep_merge(override)
  end

  def self.version
    yml = YAML.load(File.read(File.join(File.dirname(__FILE__), *%w[.. VERSION.yml])))
    "#{yml[:major]}.#{yml[:minor]}.#{yml[:patch]}"
  end
end
