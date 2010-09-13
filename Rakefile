require 'rake'
require 'spec/rake/spectask'

$:.unshift File.join(File.dirname(__FILE__), 'spec')

task :default => :test

if !defined?(Spec)
  puts "spec targets require RSpec"
else
  desc "Run all tests"
  Spec::Rake::SpecTask.new('test') do |t|
    t.spec_files = FileList['spec/**/*.rb']
    t.spec_opts = ['-cfs']
  end
end
