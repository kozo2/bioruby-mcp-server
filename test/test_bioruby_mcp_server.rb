# frozen_string_literal: true

require 'test_helper'

class TestBioRubyMCPServer < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BioRuby::MCP::Server::VERSION
  end

  def test_version_is_string
    assert_instance_of String, ::BioRuby::MCP::Server::VERSION
  end

  def test_version_format
    assert_match(/\A\d+\.\d+\.\d+\z/, ::BioRuby::MCP::Server::VERSION)
  end
end
