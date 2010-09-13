require 'rake'
require 'spec/rake/spectask'

$:.unshift File.join(File.dirname(__FILE__), 'spec')


desc "Run all tests"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

task :default => [:test]

