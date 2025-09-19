# frozen_string_literal: true

require_relative 'lib/bioruby/mcp/server/version'

Gem::Specification.new do |spec|
  spec.name = 'bioruby-mcp-server'
  spec.version = BioRuby::MCP::Server::VERSION
  spec.authors = ['Kozo Nishida']
  spec.email = ['kozo2@gmail.com']

  spec.summary = 'Model Context Protocol server for BioRuby KEGG module'
  spec.description = 'An MCP server that provides access to BioRuby KEGG functionality, ' \
                     'allowing AI assistants to query KEGG databases for biological pathways, ' \
                     'compounds, and other molecular information.'
  spec.homepage = 'https://github.com/kozo2/bioruby-mcp-server'
  spec.license = 'BSD-2-Clause'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/kozo2/bioruby-mcp-server'
  spec.metadata['changelog_uri'] = 'https://github.com/kozo2/bioruby-mcp-server/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dependencies
  spec.add_dependency 'bio', '~> 2.0'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'logger', '~> 1.0'

  # Development dependencies
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.21'
end
