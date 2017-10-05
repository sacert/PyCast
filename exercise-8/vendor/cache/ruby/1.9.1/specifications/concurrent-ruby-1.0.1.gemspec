# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "concurrent-ruby"
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jerry D'Antonio", "The Ruby Concurrency Team"]
  s.date = "2016-02-27"
  s.description = "Modern concurrency tools including agents, futures, promises, thread pools, actors, supervisors, and more.\nInspired by Erlang, Clojure, Go, JavaScript, actors, and classic concurrency patterns.\n"
  s.email = ["jerry.dantonio@gmail.com", "concurrent-ruby@googlegroups.com"]
  s.extra_rdoc_files = ["README.md", "LICENSE.txt", "CHANGELOG.md"]
  s.files = ["README.md", "LICENSE.txt", "CHANGELOG.md"]
  s.homepage = "http://www.concurrent-ruby.com"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "1.8.23"
  s.summary = "Modern concurrency tools for Ruby. Inspired by Erlang, Clojure, Scala, Haskell, F#, C#, Java, and classic concurrency patterns."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
