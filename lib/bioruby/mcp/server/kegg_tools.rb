# frozen_string_literal: true

require 'bio'
require 'net/http'
require 'uri'

module BioRuby
  module MCP
    module Server
      # KEGG-specific tools for the MCP server
      class KEGGTools
        KEGG_REST_BASE = 'http://rest.kegg.jp'

        def initialize
          # Initialize with KEGG REST API access
        end

        def available_tools
          [
            {
              'name' => 'kegg_pathway_info',
              'description' => 'Get information about a KEGG pathway',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'pathway_id' => {
                    'type' => 'string',
                    'description' => "KEGG pathway ID (e.g., 'map00010', 'hsa00010')"
                  }
                },
                'required' => ['pathway_id']
              }
            },
            {
              'name' => 'kegg_compound_info',
              'description' => 'Get information about a KEGG compound',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'compound_id' => {
                    'type' => 'string',
                    'description' => "KEGG compound ID (e.g., 'C00002', 'cpd:C00002')"
                  }
                },
                'required' => ['compound_id']
              }
            },
            {
              'name' => 'kegg_enzyme_info',
              'description' => 'Get information about a KEGG enzyme',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'enzyme_id' => {
                    'type' => 'string',
                    'description' => "KEGG enzyme ID (e.g., 'ec:1.1.1.1')"
                  }
                },
                'required' => ['enzyme_id']
              }
            },
            {
              'name' => 'kegg_search_compounds',
              'description' => 'Search for KEGG compounds by name or formula',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'query' => {
                    'type' => 'string',
                    'description' => 'Search query (compound name, formula, etc.)'
                  },
                  'database' => {
                    'type' => 'string',
                    'description' => "Database to search (default: 'compound')",
                    'default' => 'compound'
                  }
                },
                'required' => ['query']
              }
            },
            {
              'name' => 'kegg_find_pathways_by_compound',
              'description' => 'Find pathways containing a specific compound',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'compound_id' => {
                    'type' => 'string',
                    'description' => "KEGG compound ID (e.g., 'C00002')"
                  }
                },
                'required' => ['compound_id']
              }
            },
            {
              'name' => 'kegg_list_organisms',
              'description' => 'List available organisms in KEGG',
              'inputSchema' => {
                'type' => 'object',
                'properties' => {
                  'filter' => {
                    'type' => 'string',
                    'description' => 'Optional filter for organism names'
                  }
                }
              }
            }
          ]
        end

        def call_tool(tool_name, arguments)
          case tool_name
          when 'kegg_pathway_info'
            get_pathway_info(arguments['pathway_id'])
          when 'kegg_compound_info'
            get_compound_info(arguments['compound_id'])
          when 'kegg_enzyme_info'
            get_enzyme_info(arguments['enzyme_id'])
          when 'kegg_search_compounds'
            search_compounds(arguments['query'], arguments['database'] || 'compound')
          when 'kegg_find_pathways_by_compound'
            find_pathways_by_compound(arguments['compound_id'])
          when 'kegg_list_organisms'
            list_organisms(arguments['filter'])
          else
            raise "Unknown tool: #{tool_name}"
          end
        end

        private

        def kegg_get_entry(entry_id)
          uri = URI("#{KEGG_REST_BASE}/get/#{entry_id}")
          response = Net::HTTP.get_response(uri)
          return nil unless response.code == '200'

          response.body
        end

        def kegg_find_entries(database, query)
          uri = URI("#{KEGG_REST_BASE}/find/#{database}/#{query}")
          response = Net::HTTP.get_response(uri)
          return nil unless response.code == '200'

          response.body
        end

        def kegg_list_entries(database)
          uri = URI("#{KEGG_REST_BASE}/list/#{database}")
          response = Net::HTTP.get_response(uri)
          return nil unless response.code == '200'

          response.body
        end

        def get_pathway_info(pathway_id)
          # Clean up pathway ID if needed
          pathway_id = pathway_id.gsub(/^(pathway:|path:|map:)/, '')

          # Get pathway entry from KEGG REST API
          pathway_data = kegg_get_entry(pathway_id)

          if pathway_data.nil? || pathway_data.empty?
            return [{
              'type' => 'text',
              'text' => "Pathway not found: #{pathway_id}"
            }]
          end

          # Parse the pathway data using BioRuby
          pathway = Bio::KEGG::PATHWAY.new(pathway_data)

          result = []
          result << {
            'type' => 'text',
            'text' => "KEGG Pathway: #{pathway_id}\n" \
                      "Name: #{pathway.name}\n" \
                      "Description: #{pathway.description}\n" \
                      "Class: #{pathway.pathway_class}\n" \
                      "Genes: #{pathway.genes&.length || 0} genes\n" \
                      "Compounds: #{pathway.compounds&.length || 0} compounds"
          }

          if pathway.genes && !pathway.genes.empty?
            gene_list = pathway.genes.first(10).map { |gene_id, name| "#{gene_id}: #{name}" }
            result << {
              'type' => 'text',
              'text' => "Sample genes (first 10):\n#{gene_list.join("\n")}"
            }
          end

          result
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error retrieving pathway info: #{e.message}"
          }]
        end

        def get_compound_info(compound_id)
          # Clean up compound ID if needed
          compound_id = compound_id.gsub(/^(cpd:|compound:)/, '')

          # Get compound entry from KEGG REST API
          compound_data = kegg_get_entry(compound_id)

          if compound_data.nil? || compound_data.empty?
            return [{
              'type' => 'text',
              'text' => "Compound not found: #{compound_id}"
            }]
          end

          # Parse the compound data using BioRuby
          compound = Bio::KEGG::COMPOUND.new(compound_data)

          [{
            'type' => 'text',
            'text' => "KEGG Compound: #{compound_id}\n" \
              "Name: #{compound.name}\n" \
              "Formula: #{compound.formula}\n" \
              "Mass: #{compound.mass}\n" \
              "Comment: #{compound.comment}\n" \
              "Pathways: #{compound.pathways&.length || 0} pathways\n" \
              "Enzymes: #{compound.enzymes&.length || 0} enzymes"
          }]
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error retrieving compound info: #{e.message}"
          }]
        end

        def get_enzyme_info(enzyme_id)
          # Clean up enzyme ID if needed
          enzyme_id = enzyme_id.gsub(/^(ec:|enzyme:)/, '')

          # Get enzyme entry from KEGG REST API
          enzyme_data = kegg_get_entry(enzyme_id)

          if enzyme_data.nil? || enzyme_data.empty?
            return [{
              'type' => 'text',
              'text' => "Enzyme not found: #{enzyme_id}"
            }]
          end

          # Parse the enzyme data using BioRuby
          enzyme = Bio::KEGG::ENZYME.new(enzyme_data)

          [{
            'type' => 'text',
            'text' => "KEGG Enzyme: #{enzyme_id}\n" \
              "Name: #{enzyme.name}\n" \
              "Class: #{enzyme.enzyme_class}\n" \
              "Reaction: #{enzyme.reaction}\n" \
              "Substrate: #{enzyme.substrate}\n" \
              "Product: #{enzyme.product}\n" \
              "Comment: #{enzyme.comment}"
          }]
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error retrieving enzyme info: #{e.message}"
          }]
        end

        def search_compounds(query, database = 'compound')
          # Use KEGG REST API to search for compounds
          results = kegg_find_entries(database, query)

          if results.nil? || results.empty?
            return [{
              'type' => 'text',
              'text' => "No compounds found for query: #{query}"
            }]
          end

          # Parse and format results
          formatted_results = results.split("\n").first(20).map do |line|
            parts = line.split("\t")
            "#{parts[0]}: #{parts[1]}" if parts.length >= 2
          end.compact

          [{
            'type' => 'text',
            'text' => "Search results for '#{query}' (first 20):\n#{formatted_results.join("\n")}"
          }]
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error searching compounds: #{e.message}"
          }]
        end

        def find_pathways_by_compound(compound_id)
          # Clean up compound ID
          compound_id = compound_id.gsub(/^(cpd:|compound:)/, '')

          # Get compound info first to find associated pathways
          compound_data = kegg_get_entry(compound_id)

          if compound_data.nil? || compound_data.empty?
            return [{
              'type' => 'text',
              'text' => "Compound not found: #{compound_id}"
            }]
          end

          compound = Bio::KEGG::COMPOUND.new(compound_data)

          if compound.pathways.nil? || compound.pathways.empty?
            return [{
              'type' => 'text',
              'text' => "No pathways found for compound: #{compound_id}"
            }]
          end

          pathway_list = compound.pathways.map do |pathway_id, pathway_name|
            "#{pathway_id}: #{pathway_name}"
          end

          [{
            'type' => 'text',
            'text' => "Pathways containing compound #{compound_id}:\n#{pathway_list.join("\n")}"
          }]
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error finding pathways: #{e.message}"
          }]
        end

        def list_organisms(filter = nil)
          # Get list of organisms from KEGG REST API
          organism_data = kegg_list_entries('organism')

          if organism_data.nil? || organism_data.empty?
            return [{
              'type' => 'text',
              'text' => 'No organisms found'
            }]
          end

          organisms = organism_data.split("\n").map do |line|
            parts = line.split("\t")
            next unless parts.length >= 2

            org_code = parts[0]
            org_name = parts[1]
            { code: org_code, name: org_name }
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

          [{
            'type' => 'text',
            'text' => "KEGG Organisms#{filter ? " (filtered by '#{filter}')" : ''} (first 50):\n#{formatted_list.join("\n")}"
          }]
        rescue StandardError => e
          [{
            'type' => 'text',
            'text' => "Error listing organisms: #{e.message}"
          }]
        end
      end
    end
  end
end
