# coding: utf-8

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)

require 'rctl/version'

Gem::Specification.new do |s|
  s.name        = 'rctl'
  s.version     = Rctl::CtlVersion::VERSION
  s.date        = '2012-06-01'
  s.summary     = "rctl let you start and stop your service stack in one command."
  s.authors     = ["Olivier Amblet"]
  s.email       = 'olivier@amblet.net'
  s.add_development_dependency "guard", [">= 0"]
  s.add_development_dependency "guard-minitest", [">= 0"]
  s.add_development_dependency "growl", [">= 0"]
  s.add_dependency "rake", [">= 0"]
  
  s.files        = Dir.glob("{bin,lib}/**/*")
  s.executables  = ['rctl']
  s.require_path = 'lib'
  
  s.homepage    =
    'http://rctl.com'
end