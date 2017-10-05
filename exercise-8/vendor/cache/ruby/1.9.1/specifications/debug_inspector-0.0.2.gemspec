# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "debug_inspector"
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Mair (banisterfiend)"]
  s.date = "2013-02-13"
  s.description = "A Ruby wrapper for the MRI 2.0 debug_inspector API"
  s.email = ["jrmair@gmail.com"]
  s.extensions = ["ext/debug_inspector/extconf.rb"]
  s.files = ["ext/debug_inspector/extconf.rb"]
  s.homepage = "https://github.com/banister/debug_inspector"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "A Ruby wrapper for the MRI 2.0 debug_inspector API"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
