require 'rake'
require 'rake/testtask'

$:.unshift File.join(File.dirname(__FILE__), '..', "liquid", "lib")
$:.unshift File.join(File.dirname(__FILE__), 'lib' )
require 'hyde'


Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.libs << '../liquid/lib'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = false
end

task :default => [:test]

# console

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -I lib -I ../liquid/lib -r hyde.rb"
end

