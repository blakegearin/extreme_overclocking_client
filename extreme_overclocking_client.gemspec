# frozen_string_literal: true

require_relative 'lib/extreme_overclocking_client/version'

Gem::Specification.new do |spec|
  spec.name = 'extreme_overclocking_client'
  spec.version = ExtremeOverclockingClient::VERSION

  spec.authors = ['Blake Gearin']
  spec.email = 'hello@blakeg.me'

  spec.summary = 'Client for exporting Extreme Overclocking\'s Folding@home data'
  spec.description = 'Client for exporting Extreme Overclocking\'s Folding@home data'
  spec.homepage = 'https://github.com/blakegearin/extreme_overclocking_client'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/blakegearin/extreme_overclocking_client'
  spec.metadata['github_repo'] = 'ssh://github.com/blakegearin/extreme_overclocking_client'

  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end

  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '~> 7.1'
  spec.add_dependency 'nokogiri', '~> 1.16'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
