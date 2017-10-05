# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "tilt"
  s.version = "2.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Tomayko"]
  s.date = "2016-01-05"
  s.description = "Generic interface to multiple Ruby template engines"
  s.email = "r@tomayko.com"
  s.executables = ["tilt"]
  s.files = ["bin/tilt"]
  s.homepage = "http://github.com/rtomayko/tilt/"
  s.licenses = ["MIT"]
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Tilt", "--main", "Tilt"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Generic interface to multiple Ruby template engines"

  if s.respond_to? :specification_version then
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
