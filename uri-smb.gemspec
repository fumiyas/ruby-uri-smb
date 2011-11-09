# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "uri/smb/version"

Gem::Specification.new do |s|
  s.name        = "uri-smb"
  s.version     = URI::SMB::VERSION
  s.authors     = ["SATOH Fumiyasu"]
  s.email       = ["fumiyas@osstech.co.jp"]
  s.homepage    = "https://github.com/fumiyas/ruby-uri-smb"
  s.summary     = %q{SMB URI class}
  s.description = %q{SMB URI class}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 1.9.2"
end
