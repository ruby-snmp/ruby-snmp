# frozen_string_literal: true

require_relative 'lib/snmp/version'

Gem::Specification.new do |spec|
  spec.name = "snmp"
  spec.version = SNMP::VERSION
  spec.authors = ["Dave Halliday"]
  spec.email = ["hallidave@gmail.com"]

  spec.summary = "A Ruby implementation of SNMP (the Simple Network Management Protocol)."
  spec.description = "A Ruby implementation of SNMP (the Simple Network Management Protocol)."
  spec.homepage = "https://github.com/ruby-snmp/ruby-snmp"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 1.9.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ruby-snmp/ruby-snmp"
  spec.metadata["changelog_uri"] = "https://github.com/ruby-snmp/ruby-snmp/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile interop ext])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.extra_rdoc_files = ["README.md"]
  spec.rdoc_options << "--main" << "README.md" <<
    "--title" << "SNMP Library for Ruby"
end
