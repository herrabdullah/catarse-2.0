# -*- encoding: utf-8 -*-
# stub: feedjira 1.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "feedjira"
  s.version = "1.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Paul Dix", "Julien Kirch", "Ezekiel Templin", "Jon Allured"]
  s.date = "2014-12-28"
  s.description = "A library designed to retrieve and parse feeds as quickly as possible"
  s.email = "feedjira@gmail.com"
  s.homepage = "http://feedjira.com"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.8"
  s.summary = "A feed fetching and parsing library"

  s.installed_by_version = "2.4.8" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sax-machine>, ["~> 1.0"])
      s.add_runtime_dependency(%q<curb>, ["~> 0.8"])
      s.add_runtime_dependency(%q<loofah>, ["~> 2.0"])
      s.add_development_dependency(%q<rspec>, ["~> 3.0"])
    else
      s.add_dependency(%q<sax-machine>, ["~> 1.0"])
      s.add_dependency(%q<curb>, ["~> 0.8"])
      s.add_dependency(%q<loofah>, ["~> 2.0"])
      s.add_dependency(%q<rspec>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<sax-machine>, ["~> 1.0"])
    s.add_dependency(%q<curb>, ["~> 0.8"])
    s.add_dependency(%q<loofah>, ["~> 2.0"])
    s.add_dependency(%q<rspec>, ["~> 3.0"])
  end
end
