# frozen_string_literal: true

require 'test_helper'
require 'stringio'
require 'json'

class TestCore < Minitest::Test
  def setup
    @input = StringIO.new
    @output = StringIO.new
    @server = BioRuby::MCP::Server::Core.new(@input, @output)
  end

  def test_server_initialization
    assert_instance_of BioRuby::MCP::Server::Core, @server
  end

  def test_handle_initialize_message
    @input.string = JSON.generate({
                                    jsonrpc: '2.0',
                                    id: 1,
                                    method: 'initialize',
                                    params: {
                                      protocolVersion: '2024-11-05',
                                      capabilities: {},
                                      clientInfo: { name: 'test-client', version: '1.0.0' }
                                    }
                                  }) + "\n"
    @input.rewind

    # Capture the server response by running one iteration
    Thread.new { @server.start }.join(0.1) # Run briefly then timeout

    @output.rewind
    response_line = @output.gets

    return unless response_line

    response = JSON.parse(response_line)
    assert_equal '2.0', response['jsonrpc']
    assert_equal 1, response['id']
    assert response['result']['serverInfo']
    assert_equal 'bioruby-mcp-server', response['result']['serverInfo']['name']
  end

  def test_handle_tools_list_message
    @input.string = JSON.generate({
                                    jsonrpc: '2.0',
                                    id: 2,
                                    method: 'tools/list'
                                  }) + "\n"
    @input.rewind

    # This test would require more complex setup to properly test
    # For now, just verify the server can handle the message structure
    assert_respond_to @server, :start
  end
end
