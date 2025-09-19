# frozen_string_literal: true

require 'mcp'
require 'bio'
require 'open-uri'
require 'uri'

module BioRuby
  module MCP
    module Server
      # KEGG pathway information tool
      class KEGGPathwayTool < ::MCP::Tool
        tool_name 'kegg_pathway_info'
        description 'Get information about a KEGG pathway'
        input_schema(
          properties: {
            pathway_id: {
              type: 'string',
              description: 'KEGG pathway ID (e.g., "map00010", "hsa00010")'
            }
          },
          required: ['pathway_id']
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(pathway_id:, server_context: nil)
            # Clean up pathway ID if needed
            pathway_id = pathway_id.gsub(/^(pathway:|path:|map:)/, '')
            
            # Get pathway entry from KEGG REST API
            pathway_data = kegg_get_entry(pathway_id)
            
            if pathway_data.nil? || pathway_data.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "Pathway not found: #{pathway_id}"
              }])
            end

            # Parse the pathway data using BioRuby
            pathway = Bio::KEGG::PATHWAY.new(pathway_data)
            
            result = []
            result << {
              type: 'text',
              text: "KEGG Pathway: #{pathway_id}\n" \
                    "Name: #{pathway.name}\n" \
                    "Description: #{pathway.description}\n" \
                    "Class: #{pathway.pathway_class}\n" \
                    "Genes: #{pathway.genes&.length || 0} genes\n" \
                    "Compounds: #{pathway.compounds&.length || 0} compounds"
            }
            
            if pathway.genes && !pathway.genes.empty?
              gene_list = pathway.genes.first(10).map { |gene_id, name| "#{gene_id}: #{name}" }
              result << {
                type: 'text',
                text: "Sample genes (first 10):\n#{gene_list.join("\n")}"
              }
            end

            ::MCP::Tool::Response.new(result)
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error retrieving pathway info: #{e.message}"
            }])
          end

          private

          def kegg_get_entry(entry_id)
            uri = URI("#{KEGG_REST_BASE}/get/#{entry_id}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end

      # KEGG compound information tool
      class KEGGCompoundTool < ::MCP::Tool
        tool_name 'kegg_compound_info'
        description 'Get information about a KEGG compound'
        input_schema(
          properties: {
            compound_id: {
              type: 'string',
              description: 'KEGG compound ID (e.g., "C00002", "cpd:C00002")'
            }
          },
          required: ['compound_id']
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(compound_id:, server_context: nil)
            # Clean up compound ID if needed
            compound_id = compound_id.gsub(/^(cpd:|compound:)/, '')
            
            # Get compound entry from KEGG REST API
            compound_data = kegg_get_entry(compound_id)
            
            if compound_data.nil? || compound_data.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "Compound not found: #{compound_id}"
              }])
            end

            # Parse the compound data using BioRuby
            compound = Bio::KEGG::COMPOUND.new(compound_data)
            
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "KEGG Compound: #{compound_id}\n" \
                    "Name: #{compound.name}\n" \
                    "Formula: #{compound.formula}\n" \
                    "Mass: #{compound.mass}\n" \
                    "Comment: #{compound.comment}\n" \
                    "Pathways: #{compound.pathways&.length || 0} pathways\n" \
                    "Enzymes: #{compound.enzymes&.length || 0} enzymes"
            }])
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error retrieving compound info: #{e.message}"
            }])
          end

          private

          def kegg_get_entry(entry_id)
            uri = URI("#{KEGG_REST_BASE}/get/#{entry_id}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end

      # KEGG enzyme information tool
      class KEGGEnzymeTool < ::MCP::Tool
        tool_name 'kegg_enzyme_info'
        description 'Get information about a KEGG enzyme'
        input_schema(
          properties: {
            enzyme_id: {
              type: 'string',
              description: 'KEGG enzyme ID (e.g., "ec:1.1.1.1")'
            }
          },
          required: ['enzyme_id']
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(enzyme_id:, server_context: nil)
            # Clean up enzyme ID if needed  
            enzyme_id = enzyme_id.gsub(/^(ec:|enzyme:)/, '')
            
            # Get enzyme entry from KEGG REST API
            enzyme_data = kegg_get_entry(enzyme_id)
            
            if enzyme_data.nil? || enzyme_data.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "Enzyme not found: #{enzyme_id}"
              }])
            end

            # Parse the enzyme data using BioRuby
            enzyme = Bio::KEGG::ENZYME.new(enzyme_data)
            
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "KEGG Enzyme: #{enzyme_id}\n" \
                    "Name: #{enzyme.name}\n" \
                    "Class: #{enzyme.enzyme_class}\n" \
                    "Reaction: #{enzyme.reaction}\n" \
                    "Substrate: #{enzyme.substrate}\n" \
                    "Product: #{enzyme.product}\n" \
                    "Comment: #{enzyme.comment}"
            }])
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error retrieving enzyme info: #{e.message}"
            }])
          end

          private

          def kegg_get_entry(entry_id)
            uri = URI("#{KEGG_REST_BASE}/get/#{entry_id}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end

      # KEGG compound search tool
      class KEGGSearchTool < ::MCP::Tool
        tool_name 'kegg_search_compounds'
        description 'Search for KEGG compounds by name or formula'
        input_schema(
          properties: {
            query: {
              type: 'string',
              description: 'Search query (compound name, formula, etc.)'
            },
            database: {
              type: 'string',
              description: 'Database to search (default: "compound")',
              default: 'compound'
            }
          },
          required: ['query']
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(query:, database: 'compound', server_context: nil)
            # Use KEGG REST API to search for compounds
            results = kegg_find_entries(database, query)
            
            if results.nil? || results.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "No compounds found for query: #{query}"
              }])
            end

            # Parse and format results
            formatted_results = results.split("\n").first(20).map do |line|
              parts = line.split("\t")
              "#{parts[0]}: #{parts[1]}" if parts.length >= 2
            end.compact

            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Search results for '#{query}' (first 20):\n#{formatted_results.join("\n")}"
            }])
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error searching compounds: #{e.message}"
            }])
          end

          private

          def kegg_find_entries(database, query)
            uri = URI("#{KEGG_REST_BASE}/find/#{database}/#{query}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end

      # KEGG pathway finder tool
      class KEGGPathwayFinderTool < ::MCP::Tool
        tool_name 'kegg_find_pathways_by_compound'
        description 'Find pathways containing a specific compound'
        input_schema(
          properties: {
            compound_id: {
              type: 'string',
              description: 'KEGG compound ID (e.g., "C00002")'
            }
          },
          required: ['compound_id']
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(compound_id:, server_context: nil)
            # Clean up compound ID
            compound_id = compound_id.gsub(/^(cpd:|compound:)/, '')
            
            # Get compound info first to find associated pathways
            compound_data = kegg_get_entry(compound_id)
            
            if compound_data.nil? || compound_data.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "Compound not found: #{compound_id}"
              }])
            end

            compound = Bio::KEGG::COMPOUND.new(compound_data)
            
            if compound.pathways.nil? || compound.pathways.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: "No pathways found for compound: #{compound_id}"
              }])
            end

            pathway_list = compound.pathways.map do |pathway_id, pathway_name|
              "#{pathway_id}: #{pathway_name}"
            end

            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Pathways containing compound #{compound_id}:\n#{pathway_list.join("\n")}"
            }])
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error finding pathways: #{e.message}"
            }])
          end

          private

          def kegg_get_entry(entry_id)
            uri = URI("#{KEGG_REST_BASE}/get/#{entry_id}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end

      # KEGG organism list tool
      class KEGGOrganismTool < ::MCP::Tool
        tool_name 'kegg_list_organisms'
        description 'List available organisms in KEGG'
        input_schema(
          properties: {
            filter: {
              type: 'string',
              description: 'Optional filter for organism names'
            }
          }
        )

        KEGG_REST_BASE = 'http://rest.kegg.jp'

        class << self
          def call(filter: nil, server_context: nil)
            # Get list of organisms from KEGG REST API
            organism_data = kegg_list_entries('organism')
            
            if organism_data.nil? || organism_data.empty?
              return ::MCP::Tool::Response.new([{
                type: 'text',
                text: 'No organisms found'
              }])
            end

            organisms = organism_data.split("\n").map do |line|
              parts = line.split("\t")
              if parts.length >= 2
                org_code = parts[0]
                org_name = parts[1]
                { code: org_code, name: org_name }
              end
            end.compact

            # Apply filter if provided
            if filter
              organisms = organisms.select do |org|
                org[:name].downcase.include?(filter.downcase) ||
                org[:code].downcase.include?(filter.downcase)
              end
            end

            # Limit results and format
            organisms = organisms.first(50)
            formatted_list = organisms.map { |org| "#{org[:code]}: #{org[:name]}" }

            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "KEGG Organisms#{filter ? " (filtered by '#{filter}')" : ''} (first 50):\n#{formatted_list.join("\n")}"
            }])
          rescue => e
            ::MCP::Tool::Response.new([{
              type: 'text',
              text: "Error listing organisms: #{e.message}"
            }])
          end

          private

          def kegg_list_entries(database)
            uri = URI("#{KEGG_REST_BASE}/list/#{database}")
            begin
              uri.open.read
            rescue OpenURI::HTTPError
              nil
            end
          end
        end
      end
    end
  end
end