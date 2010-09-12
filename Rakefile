require 'rake'
require 'spec/rake/spectask'

$:.unshift File.join(File.dirname(__FILE__), 'lib')


desc "Run all tests"
Spec::Rake::SpecTask.new('test') do |t|
  t.spec_files = FileList['test/**/*.rb']
end

task :default => [:test]

