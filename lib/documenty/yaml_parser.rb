require 'yaml'

module Documenty
  ## 
  # Turns an .yml file into a HTML file describing an API.
  class YamlAPIParser
    # These fields are required, Documently will yield an error
    # if one of them is not present.
    REQUIRED_FIELDS = [
      "Name", "Version", "Path Prefix"
    ]

    DEFAULT_METHODS = {
      "create"  => "POST",
      "index"   => "GET",
      "show"    => "GET",
      "update"  => "PUT",
      "destroy" => "DELETE"
    }

    # == Parameters:
    # yaml_file: A valid path to your documentation yaml file
    def initialize(yaml_file)
      @base = {}
      @resources = {}
      @descriptions = {}
      @errors = {
      }
      @valid = true

      unless File.exists? yaml_file
        raise(ArgumentError, ":yaml_file must be a valid file path")
      end

      @yaml = YAML.load_file(yaml_file)

      parse_base
      parse_resources
      parse_descriptions
    end

    def attributes
      {
        base: @base,
        resources: @resources,
        descriptions: @descriptions
      }
    end

    def errors
      @errors
    end

    def valid?
      @valid
    end

    private
    def add_error(where, what, *fields) 
      @errors[where] ||= {}
      @errors[where][fields] ||= []
      @errors[where][fields] << what
      @valid = false
    end

    def parse_base
      @base = @yaml["Base"]
      REQUIRED_FIELDS.each do |field|
        unless @base[field]
          add_error(:base, "is missing", field)
        end
      end
    end

    def parse_resources
      resources = @yaml["Resources"].split(', ')
      @resources = resources
    end

    def parse_descriptions
      @descriptions = @yaml["Descriptions"]
      missing_descriptions = @resources - @descriptions.keys
      missing_descriptions.each do |missing_description|
        add_error(:descriptions, "is missing", missing_description)
      end

      @descriptions.each do |resource, resource_keys|
        resource_keys["actions"].each do |action, action_keys|
          unless action_keys["method"]
            if DEFAULT_METHODS.include? action
              action_keys["method"] = DEFAULT_METHODS[action]
            else
              add_error(:descriptions, "does not specify a HTTP method", resource, action)
            end
          end
        end
      end
    end
  end
end