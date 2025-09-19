# frozen_string_literal: true

require 'json'
require 'logger'
require 'bio'

module BioRuby
  module MCP
    module Server
      # Core MCP server implementation following MCP protocol specification
      class Core
        def initialize(input_stream = $stdin, output_stream = $stdout)
          @input = input_stream
          @output = output_stream
          @logger = Logger.new($stderr)
          @tools = KEGGTools.new
          @server_info = {
            name: 'bioruby-mcp-server',
            version: VERSION
          }
        end

        def start
          @logger.info("Starting BioRuby MCP Server #{VERSION}")

          # Initialize the server and enter the main message processing loop
          loop do
            line = @input.gets
            break if line.nil?

            message = JSON.parse(line.strip)
            response = handle_message(message)
            send_response(response) if response
          rescue JSON::ParserError => e
            @logger.error("JSON parsing error: #{e.message}")
            send_error_response('Invalid JSON', message&.dig('id'))
          rescue StandardError => e
            @logger.error("Unexpected error: #{e.message}")
            send_error_response('Internal server error', message&.dig('id'))
          end
        end

        private

        def handle_message(message)
          method = message['method']
          params = message['params'] || {}
          id = message['id']

          case method
          when 'initialize'
            handle_initialize(params, id)
          when 'tools/list'
            handle_tools_list(id)
          when 'tools/call'
            handle_tool_call(params, id)
          when 'ping'
            handle_ping(id)
          else
            send_error_response("Method not found: #{method}", id)
          end
        end

        def handle_initialize(_params, id)
          {
            jsonrpc: '2.0',
            id: id,
            result: {
              protocolVersion: '2024-11-05',
              capabilities: {
                tools: {}
              },
              serverInfo: @server_info
            }
          }
        end

        def handle_tools_list(id)
          {
            jsonrpc: '2.0',
            id: id,
            result: {
              tools: @tools.available_tools
            }
          }
        end

        def handle_tool_call(params, id)
          tool_name = params['name']
          arguments = params['arguments'] || {}

          begin
            result = @tools.call_tool(tool_name, arguments)
            {
              jsonrpc: '2.0',
              id: id,
              result: {
                content: result
              }
            }
          rescue StandardError => e
            @logger.error("Tool call error: #{e.message}")
            send_error_response("Tool execution failed: #{e.message}", id)
          end
        end

        def handle_ping(id)
          {
            jsonrpc: '2.0',
            id: id,
            result: {}
          }
        end

        def send_response(response)
          @output.puts JSON.generate(response)
          @output.flush
        end

        def send_error_response(message, id = nil)
          response = {
            jsonrpc: '2.0',
            id: id,
            error: {
              code: -1,
              message: message
            }
          }
          send_response(response)
        end
      end
    end
  end
end
