# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{prep}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tetsuhisa MAKINO"]
  s.date = %q{2011-03-20}
  s.description = %q{PREP is PDF Report generator depends on HPDF.}
  s.email = %q{tim.makino@gmail.com}
  s.executables = ["prep-test", "prep-helper"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/prep-helper",
    "bin/prep-test",
    "examples/generate_group_sample.rb",
    "examples/generate_sample.rb",
    "examples/generate_sample2.rb",
    "examples/generate_sample3.rb",
    "examples/generate_sample4.rb",
    "examples/generate_sample5.rb",
    "examples/generate_sample6.rb",
    "examples/generate_sample_dataset.rb",
    "examples/group_sample.yml",
    "examples/sample.yml",
    "examples/sample2.yml",
    "examples/sample3.yml",
    "examples/sample5.yml",
    "examples/sample6.yml",
    "lib/core/color.rb",
    "lib/core/drawable.rb",
    "lib/core/group.rb",
    "lib/core/label.rb",
    "lib/core/line.rb",
    "lib/core/loop.rb",
    "lib/core/page.rb",
    "lib/core/point.rb",
    "lib/core/prep.rb",
    "lib/core/rectangle.rb",
    "lib/core/region.rb",
    "lib/mm2pixcel.rb",
    "lib/prep.rb",
    "prep.gemspec",
    "spec/component_spec.rb",
    "spec/prep_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/maki-tetsu/prep}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{PREP is PDF Report generator depends on HPDF.}
  s.test_files = [
    "examples/generate_group_sample.rb",
    "examples/generate_sample.rb",
    "examples/generate_sample2.rb",
    "examples/generate_sample3.rb",
    "examples/generate_sample4.rb",
    "examples/generate_sample5.rb",
    "examples/generate_sample6.rb",
    "examples/generate_sample_dataset.rb",
    "spec/component_spec.rb",
    "spec/prep_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<hpdf>, [">= 2.0.8"])
      s.add_development_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<hpdf>, [">= 2.0.8"])
      s.add_dependency(%q<rspec>, ["~> 2.3.0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<hpdf>, [">= 2.0.8"])
    s.add_dependency(%q<rspec>, ["~> 2.3.0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

