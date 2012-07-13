require 'documenty'
require 'haml'
require 'fileutils'
require 'uri'

module Documenty
  module RenderHelper
    # Turns a Rails path (yes, this is such a rails specific method :/)
    # like /customers/:id/purchases/:id
    # into get/customers/id/purchases/id.html
    # TODO: Figure out a platform neutral ways to do this
    def escaped_action_path(path, method='GET')
      new_path = /([\/:\w]+)/.match(path)[0]
      new_path.gsub!(':', '')
      new_path = "#{method}#{new_path}.html"
      #URI.escape(new_path, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).to_s
    end

    # Concatenates n paths, adds a scheme if none is found
    # Lastly it removes any duplicate slashes
    def concatenate_paths(*paths)
      return nil if paths.nil? || paths.empty?
      path = paths.join('/')
      uri = URI.parse(path)
      scheme = uri.scheme.nil? ? 'http' : uri.scheme
      path = path.split(/([file|https|http]+\:\/{2})/).last
      path.gsub!(/\/{2,}/, '/') # Remove any // occurences that might have come along
      "#{scheme}://#{path}"
    end

    def link_for_action(keys)
      concatenate_paths(@base["url"], escaped_action_path(keys['path'], keys['method']))
    end

    def stylesheet_path
      concatenate_paths(@base["url"], 'style.css')
    end
  end

  # Scope for our templates
  # @param attributes Documenty attributes (Documenty.new(...).attributes) 
  class IndexScope
    include RenderHelper

    def initialize(attributes)
      @attributes = attributes
      @resources = @attributes["resources"]
      @base = @attributes["base"]
    end
  end

  class ResourceScope
    include RenderHelper

    def initialize(name, attributes, base)
      @name = name
      @attributes = attributes
      @base = base
    end
  end

  class Renderer
    include RenderHelper

    # @param attributes Documenty attributes (Documenty.new(...).attributes) 
    def self.render(attributes, options={})
      self.new(attributes, options)
    end

    def initialize(attributes, options={})
      @options = {
        :template_dir => File.expand_path('../../../templates', __FILE__),
        :css_file => File.expand_path('../../../templates/style.css', __FILE__),
        :output_directory => './apidoc/'
      }.merge(options)

      @attributes = attributes

      # TODO: Handle exceptions
      FileUtils::mkdir_p( @options[:output_directory] )

      render_index
      render_resources

      FileUtils::copy(
          @options[:css_file],
          File.join(@options[:output_directory], 'style.css')
      )
    end

    def render_resources
      resource_file = File.join(@options[:template_dir], 'resource.haml')
      resource_template = File.read(resource_file)
      resource_engine = Haml::Engine.new(resource_template, {filename: resource_file})

      @attributes["resources"].each do |resource, resource_keys|
        resource_keys["actions"].each do |action, action_keys|
          resource_path = File.join(
                                @options[:output_directory], 
                                escaped_action_path(action_keys['path'], action_keys['method']))

          # TODO: Handle exceptions
          FileUtils::mkdir_p( File.dirname(resource_path) )

          File.write(
            resource_path, 
            resource_engine.render(ResourceScope.new(action, action_keys, @attributes["base"])) 
          )
        end
      end
    end

    def render_index
      index_file = File.join(@options[:template_dir], 'index.haml')
      index_template = File.read(index_file)
      index_engine = Haml::Engine.new(index_template, {filename: index_file} )
      index_path = File.join( @options[:output_directory], 'index.html' )

      File.write(index_path, index_engine.render(IndexScope.new(@attributes)) )
    end
  end
end
